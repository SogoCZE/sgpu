init_renderdoc :: () {
    #if OS == .LINUX {
        #import "POSIX";

        mod := dlopen("./librenderdoc.so", RTLD_NOW | RTLD_GLOBAL);
        assert(mod != null);
        get_api := cast(pRENDERDOC_GetAPI)dlsym(mod, "RENDERDOC_GetAPI");
    } else {
        #import "Windows";

        mod := GetModuleHandleA("renderdoc.dll");
        assert(mod != null);
        get_api := cast(pRENDERDOC_GetAPI)GetProcAddress(mod, "RENDERDOC_GetAPI");
    }

    ret := get_api(.eRENDERDOC_API_Version_1_6_0, cast(**void)(*rdoc_api));
    assert(ret == 1);
}

rdoc_api: *RENDERDOC_API_1_6_0;

#import,file "../../simp_gpu/module.jai"(VALIDATION = true);
#import,file "../../simp_gpu/modules/renderdoc/module.jai";