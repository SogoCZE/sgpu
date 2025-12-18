main :: () {
    gpu_init();

    ptr := gpu_malloc(1024);
    _, gpu_ptr := gpu_malloc(1024, .GPU);

    memset(ptr, 255, 1024);

    gpu_free(ptr);
    gpu_free(gpu_ptr);

    main_queue := gpu_get_queue(.MAIN, 0);
    c1_queue := gpu_get_queue(.COMPUTE, 0);
    c2_queue := gpu_get_queue(.COMPUTE, 1);

    for 0..200 {
        for 0..127 {
            cmd_buff := gpu_start_command_recording(main_queue);

            gpu_submit(main_queue, cmd_buff);

            cmd_buff = gpu_start_command_recording(c1_queue);
            gpu_submit(c1_queue, cmd_buff);

            cmd_buff = gpu_start_command_recording(c2_queue);
            gpu_submit(c1_queue, cmd_buff);
        }

        gpu_wait_idle();
    }

    gpu_shutdown();
}

#import,file "../../simp_gpu/module.jai"(VALIDATION = true);