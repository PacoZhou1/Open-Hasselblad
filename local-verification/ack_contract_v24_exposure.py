"""Pure v16 generation-bound DNG ACK gate. Native recovery and actual files checked separately."""
FRAME_BYTES=23100928
SOURCE_BYTES=23379456
SLOT_STRIDE=23101440
MAX_FRAMES=240
MAX_BYTES=FRAME_BYTES*MAX_FRAMES
PREFAULT_BYTES=SLOT_STRIDE*3
MAX_EXACT=9007199254740991
FIELDS=('id','timestamp_native','bytes','written','slot','generation','admission_ns',
        'copy_begin_ns','copy_end_ns','write_begin_ns','write_end_ns',
        'copy_cpu_clock_valid','copy_cpu_wall_consistent','copy_cpu_begin_ns','copy_cpu_end_ns','src_mod64','dst_mod64',
        'mem_flags_rc','mem_flags','mem_fd_rc','mem_fd',
        'write_cpu_clock_valid','write_cpu_wall_consistent','write_cpu_begin_ns','write_cpu_end_ns',
        'write_src_mod512','write_src_mod4096','write_offset')

def number(rx,key,minimum=0,maximum=MAX_EXACT):
    n=rx[key]
    assert type(n) is int and minimum<=n<=maximum,key
    return n

def validate_capture(rx,expected_generation=None):
    validate_closure(rx,expected_generation)
    assert rx['scope']=='receiver_cpu_drain'
    fixed=dict(version=16,rc=0,state=5,error=0,drain_attempted=1,drain_rc=0,cpu_drained=1,
        no_arm=0,trigger_seen=1,capture_armed=1,callback_active=0,expired=0,
        expected_bytes=MAX_BYTES,max_frame_count=240,expected_frame_bytes=FRAME_BYTES,
        slot_count=3,copy_active=0,sequence_error=0,prefault_bytes=PREFAULT_BYTES,
        capture_success=1,admission_closed=1,fsync_ok=1,binding_pinned=1,got_is_hook=1,
        hook_window_closed=1,vendor_error=0,hal_unmap_error=0,expected_pixel=10001,
        writer_direct_required=1,cpu_pool_mod4096=0,writer_fsync_clock_valid=1,
        writer_provider_pinned=1,writer_provider_kind=1)
    for k,v in fixed.items():assert number(rx,k)==v,k
    for k,v in dict(copy_provider_pinned=1,copy_provider_kind=1).items():assert number(rx,k)==v,k
    assert rx['copy_provider_path']=='/system/lib64/libc.so'
    base=number(rx,'copy_provider_base',1);offset=number(rx,'copy_provider_offset',1)
    assert offset==0x1e590 and number(rx,'copy_provider_address',1)==base+offset
    assert rx['writer_provider_path']=='/system/lib64/libc.so'
    assert number(rx,'writer_provider_base',1)==base
    for symbol,expected in [('pwrite',0x70c40),('fsync',0x70700)]:
        assert number(rx,'writer_provider_'+symbol+'_offset')==expected
        assert number(rx,'writer_provider_'+symbol+'_address')==base+expected
    before=number(rx,'directory_flags_before');active=number(rx,'directory_flags_active')
    assert before&3==0 and not before&(0x400|0x10000|0x101000)
    assert active==before
    count=number(rx,'frames_copied',2,240)
    assert number(rx,'frames_reserved')==number(rx,'frames_written')==count
    total=number(rx,'bytes_written');assert total==count*FRAME_BYTES
    reason=number(rx,'stop_reason',1,6)
    assert reason in (1,2,6)
    cs=number(rx,'constructor_start_ns',1);cd=number(rx,'constructor_deadline_ns',1)
    arm=number(rx,'arm_ns',1);deadline=number(rx,'admission_deadline_ns',1)
    closed=number(rx,'admission_closed_ns',1);done=number(rx,'writer_done_ns',1)
    assert cs<cd and cd-cs<=70000000000 and cs<=arm<cd
    assert deadline==min(arm+10000000000,cd) and deadline<=cd and arm<=closed<=done<=cd
    assert (reason==1 and closed>=deadline) or (reason==2 and count==240) or reason==6
    shape=dict(pixel_28=10001,aux_2c=0,width=3920,height=2946,stride=7936,offset=0,planeheight=2946,planes=1)
    assert 1<=len(rx['samples'])<=8 and all(s==shape and all(type(v) is int for v in s.values()) for s in rx['samples'])
    for key in ['seen','rejected','drop_full','drop_copy_busy']:number(rx,key)
    assert rx['seen']>=count and rx['rejected']==rx['drop_full']==rx['drop_copy_busy']==0
    assert rx['dng_published_frames']==count
    for k in ['dng_manifest_published','dng_directory_synced','dng_context_released']:assert rx[k]==1,k
    assert rx['dng_error']==rx['dng_close_error']==0
    last_id=last_stamp=last_admission=last_copy_end=last_write_end=0
    generations=[0]*3;slot_write_end=[0]*3;frames=[]
    for j in range(240):
        f={k:number(rx,f'frame{j}_{k}',-2147483648 if k in SIGNED_FRAME else 0,2147483647 if k in SIGNED_FRAME else MAX_EXACT) for k in FIELDS}
        if j>=count:
            assert all(v==0 for v in f.values()),f'nonzero unused frame{j}'
            continue
        assert last_id<f['id']<=4294967295 and last_stamp<f['timestamp_native']
        assert f['bytes']==FRAME_BYTES and f['written']==1 and f['slot']<3
        slot=f['slot'];assert f['generation']==generations[slot]+1
        a,cb,ce,wb,we=(f[k] for k in ['admission_ns','copy_begin_ns','copy_end_ns','write_begin_ns','write_end_ns'])
        assert arm<=a<deadline and a<=closed and a>last_admission
        assert a<=cb<=ce<=wb<=we<=done
        assert cb>=last_copy_end and wb>=last_write_end and cb>=slot_write_end[slot]
        assert f['copy_cpu_clock_valid']==1
        cpb,cpe=f['copy_cpu_begin_ns'],f['copy_cpu_end_ns']
        assert 0<cpb<=cpe
        assert f['copy_cpu_wall_consistent']==int(cpe-cpb<=ce-cb)
        wpb,wpe=f['write_cpu_begin_ns'],f['write_cpu_end_ns']
        assert f['write_cpu_clock_valid']==1 and 0<wpb<=wpe
        assert f['write_cpu_wall_consistent']==int(wpe-wpb<=we-wb)
        assert f['write_src_mod512']==0 and f['write_src_mod4096']==0
        assert f['write_offset']==0
        generations[slot]=f['generation'];slot_write_end[slot]=we
        last_id,last_stamp,last_admission,last_copy_end,last_write_end=f['id'],f['timestamp_native'],a,ce,we
        f.update(index=j,offset=0);frames.append(f)
    assert number(rx,'frame_id')==last_id and number(rx,'timestamp_native')==last_stamp
    fwb=number(rx,'writer_fsync_wall_begin_ns',1);fwe=number(rx,'writer_fsync_wall_end_ns',1)
    fcb=number(rx,'writer_fsync_cpu_begin_ns',1);fce=number(rx,'writer_fsync_cpu_end_ns',1)
    assert last_write_end<=fwb<=fwe<=done and 0<fcb<=fce
    assert rx['writer_fsync_cpu_wall_consistent']==int(fce-fcb<=fwe-fwb)
    return dict(count=count,total_bytes=total,frames=frames,stop_reason=reason,
        cpu_admission_intervals_ns=[frames[i+1]['admission_ns']-frames[i]['admission_ns'] for i in range(count-1)],
        cpu_write_completion_intervals_ns=[frames[i+1]['write_end_ns']-frames[i]['write_end_ns'] for i in range(count-1)],
        native_timestamp_deltas=[frames[i+1]['timestamp_native']-frames[i]['timestamp_native'] for i in range(count-1)],
        native_timestamp_unit='unverified',sensor_exposure_fps_verified=False,
        copy_provider={k:rx[k] for k in PROVIDER_FIELDS},
        cpu_copy_wall_ns=[f['copy_end_ns']-f['copy_begin_ns'] for f in frames],
        cpu_copy_thread_ns=[f['copy_cpu_end_ns']-f['copy_cpu_begin_ns'] for f in frames],
        cpu_wall_quality_false_frame_indices=[f['index'] for f in frames if f['copy_cpu_wall_consistent']==0],
        writer_provider={k:rx[k] for k in WRITER_PROVIDER_FIELDS},
        directory_flags_before=before,directory_flags_active=active,
        cpu_write_wall_ns=[f['write_end_ns']-f['write_begin_ns'] for f in frames],
        cpu_write_thread_ns=[f['write_cpu_end_ns']-f['write_cpu_begin_ns'] for f in frames],
        writer_cpu_wall_quality_false_frame_indices=[f['index'] for f in frames if not f['write_cpu_wall_consistent']],
        writer_fsync_wall_ns=fwe-fwb,writer_fsync_thread_ns=fce-fcb,
        writer_fsync_cpu_wall_consistent=rx['writer_fsync_cpu_wall_consistent'],
        direct_writer_verified=True)


SIGNED_FRAME={'mem_flags_rc','mem_fd_rc','mem_fd'}
PROVIDER_FIELDS=('copy_provider_pinned','copy_provider_kind','copy_provider_path',
                 'copy_provider_base','copy_provider_offset','copy_provider_address')
WRITER_PROVIDER_FIELDS=('writer_provider_pinned','writer_provider_kind','writer_provider_path',
 'writer_provider_base','writer_provider_pwrite_offset','writer_provider_pwrite_address',
 'writer_provider_fsync_offset','writer_provider_fsync_address')
WRITER_TOP_FIELDS=('writer_direct_required','directory_flags_before','directory_flags_active','cpu_pool_mod4096',
 'writer_fsync_clock_valid','writer_fsync_cpu_wall_consistent','writer_fsync_wall_begin_ns',
 'writer_fsync_wall_end_ns','writer_fsync_cpu_begin_ns','writer_fsync_cpu_end_ns')
TOP_FIELDS=('scope','version','clip_generation','rc','state','error','drain_attempted','drain_rc','cpu_drained',
 'no_arm','trigger_seen','capture_armed','frame_id','timestamp_native','callback_active','expired',
 'expected_bytes','max_frame_count','expected_frame_bytes','slot_count','frames_reserved',
 'frames_copied','frames_written','bytes_written','copy_active','sequence_error','prefault_bytes',
 'capture_success','stop_reason','drop_full','drop_copy_busy','admission_closed','constructor_start_ns',
 'constructor_deadline_ns','arm_ns','admission_deadline_ns','admission_closed_ns','writer_done_ns','fsync_ok',
 'binding_pinned','got_is_hook','hook_window_closed','seen','rejected','vendor_error','hal_unmap_error',
 'expected_pixel','samples','storage_format','source_frame_bytes','pixel_bytes','slot_stride','dng_published_frames','dng_manifest_published','dng_directory_synced','dng_context_released','dng_error','dng_close_error')+WRITER_TOP_FIELDS
BITS={'drain_attempted','cpu_drained','no_arm','trigger_seen','capture_armed','callback_active',
 'expired','capture_success','admission_closed','fsync_ok','binding_pinned','got_is_hook',
 'hook_window_closed','copy_provider_pinned','copy_provider_kind','writer_provider_pinned','writer_provider_kind',
 'writer_direct_required','writer_fsync_clock_valid','writer_fsync_cpu_wall_consistent','dng_manifest_published','dng_directory_synced','dng_context_released'}
SIGNED_TOP={'rc','error','drain_rc','sequence_error','vendor_error','hal_unmap_error','directory_flags_before','directory_flags_active'}
SAMPLE_FIELDS={'pixel_28','aux_2c','width','height','stride','offset','planeheight','planes'}

def validate_closure(rx,expected_generation=None):
    generation=number(rx,"clip_generation",1,2)
    if expected_generation is not None:
        assert type(expected_generation) is int and expected_generation in (1,2)
        assert generation==expected_generation,"wrong clip generation"
    expected=set(TOP_FIELDS)|set(PROVIDER_FIELDS)|set(WRITER_PROVIDER_FIELDS)|{f'frame{j}_{k}' for j in range(240) for k in FIELDS}
    assert type(rx) is dict and set(rx)==expected,'ACK exact key set'
    assert rx['scope']=='receiver_cpu_drain' and rx['copy_provider_path'] in ('','/system/lib64/libc.so')
    assert rx['writer_provider_path'] in ('','/system/lib64/libc.so')
    assert rx['storage_format']=='DNG_SEQUENCE_PROVISIONAL'
    assert rx['source_frame_bytes']==SOURCE_BYTES and rx['pixel_bytes']==23096640 and rx['slot_stride']==SLOT_STRIDE
    for k in set(TOP_FIELDS)|set(PROVIDER_FIELDS)|set(WRITER_PROVIDER_FIELDS):
        if k in ('scope','samples','copy_provider_path','writer_provider_path','storage_format'):continue
        number(rx,k,-2147483648 if k in SIGNED_TOP else 0,2147483647 if k in SIGNED_TOP else (1 if k in BITS else MAX_EXACT))
    for k,v in dict(version=16,drain_attempted=1,drain_rc=0,cpu_drained=1,callback_active=0,
          expected_bytes=MAX_BYTES,max_frame_count=240,expected_frame_bytes=FRAME_BYTES,
          slot_count=3,copy_active=0,admission_closed=1,hook_window_closed=1,
          hal_unmap_error=0,expected_pixel=10001).items():assert rx[k]==v,k
    assert rx['state'] in (0,5,6,7) and 0<=rx['stop_reason']<=6
    number(rx,'cpu_pool_mod4096',0,4095)
    reserved=number(rx,'frames_reserved',0,240);copied=number(rx,'frames_copied',0,reserved)
    written=number(rx,'frames_written',0,copied);size=number(rx,'bytes_written',0,MAX_BYTES)
    assert written*FRAME_BYTES<=size<=copied*FRAME_BYTES and rx['prefault_bytes']<=PREFAULT_BYTES
    for j in range(240):
        for k in FIELDS:
            lo=-2147483648 if k in SIGNED_FRAME else 0
            hi=2147483647 if k in SIGNED_FRAME else MAX_EXACT
            if k in ('written','copy_cpu_clock_valid','copy_cpu_wall_consistent','write_cpu_clock_valid','write_cpu_wall_consistent'):hi=1
            if k in ('src_mod64','dst_mod64'):hi=63
            if k=='write_src_mod512':hi=511
            if k=='write_src_mod4096':hi=4095
            if k=='write_offset':hi=MAX_BYTES
            if k in ('id','mem_flags'):hi=4294967295
            number(rx,f'frame{j}_{k}',lo,hi)
    assert type(rx['samples']) is list and len(rx['samples'])<=8
    for sample in rx['samples']:
        assert type(sample) is dict and set(sample)==SAMPLE_FIELDS
        for k in SAMPLE_FIELDS:number(sample,k,0,MAX_EXACT)
    return dict(scope='receiver_cpu_drain',safe_cpu_closure=True,native_dma_fence=False)


def validate_configuration_applied(rx):
    count=number(rx,'frames_copied',2,240)
    for j in range(count):
        for suffix,expected in (('mem_flags_rc',0),('mem_flags',17),('mem_fd_rc',0)):
            assert number(rx,f'frame{j}_{suffix}')==expected,f'frame{j}_{suffix}'
    return dict(configuration_applied_verified=True,expected_mem_flags=17,diagnostic_getters_rc_verified=0)

def validate_success(rx,expected_generation=None):
    result=validate_capture(rx,expected_generation)
    result.update(validate_configuration_applied(rx))
    result['capture_success_verified']=True
    return result


def validate_pair(first,second):
    """Two captures within one source deadline; not a source/DMA ownership proof."""
    a=validate_success(first,1);b=validate_success(second,2)
    assert first['constructor_deadline_ns']==second['constructor_deadline_ns'],'deadline reset between clips'
    assert first['writer_done_ns']<=second['arm_ns'],'clip overlap'
    assert first['frame_id']<second['frame0_id'],'source frame identity did not advance'
    assert first['timestamp_native']<second['frame0_timestamp_native'],'source timestamp did not advance'
    assert first['copy_provider_base']==second['copy_provider_base'],'provider instance changed'
    return {'clips':[a,b],'shared_absolute_deadline':True,'source_continuity_proof':'frame/timestamp ordering only; native owner identity verified separately'}
