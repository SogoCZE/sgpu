Gpu_Ptr :: #type,distinct u64;

Memory_Type :: enum {
    DEFAULT;
    GPU;
    READBACK;
}

Memory_Layout :: struct {
    size: s64;
    align: s64;
}

gpu_malloc :: (size: u64, align: u64 = 0, memory_type: Memory_Type = .DEFAULT) -> (mapped: *void, gpu: Gpu_Ptr) {
    memory_flags: VkMemoryPropertyFlagBits;
    if #complete memory_type == {
        case .DEFAULT;
            memory_flags |= .HOST_VISIBLE_BIT | .HOST_COHERENT_BIT;
        case .GPU;
            memory_flags |= .DEVICE_LOCAL_BIT;
        case .READBACK;
            memory_flags |= .HOST_VISIBLE_BIT | .HOST_CACHED_BIT | .HOST_COHERENT_BIT;
    }

    buffer_create_info := VkBufferCreateInfo.{
        flags = .DEVICE_ADDRESS_CAPTURE_REPLAY_BIT,
        usage = .STORAGE_BUFFER_BIT | .SHADER_DEVICE_ADDRESS_BIT,
        size = size,
        sharingMode = .CONCURRENT,
        queueFamilyIndexCount = all_queue_family_indices.count.(u32),
        pQueueFamilyIndices = all_queue_family_indices.data
    };

    alloc_create_info := VmaAllocationCreateInfo.{
        flags = ifx memory_type != .GPU then .MAPPED_BIT,
        requiredFlags = memory_flags
    };


    alloc_info := VmaAllocationInfo.{};
    
    result: Alloc_Info;
    vk_result := vmaCreateBuffer(vma, *buffer_create_info, *alloc_create_info, *result.buffer, *result.allocation, *alloc_info);
    assert_vk_result(vk_result);

    addr_info := VkBufferDeviceAddressInfo.{buffer = result.buffer };
    result.gpu_ptr = cast(Gpu_Ptr) vkGetBufferDeviceAddress(vk_device, *addr_info);
    assert(result.gpu_ptr != 0);

    if memory_type != .GPU {
        mapped := alloc_info.pMappedData;
        table_add(*allocations, mapped, result);
        return mapped, result.gpu_ptr;
    } else {
        table_add(*gpu_allocations, result.gpu_ptr, result);
        return null, result.gpu_ptr;
    }
}

gpu_free :: (ptr: *void) {
    removed, alloc := table_remove(*allocations, ptr);
    if removed {
        vmaDestroyBuffer(vma, alloc.buffer, alloc.allocation);
    }
}

gpu_free :: (gpu_ptr: Gpu_Ptr) {
    removed, alloc := table_remove(*gpu_allocations, gpu_ptr);
    if removed {
        vmaDestroyBuffer(vma, alloc.buffer, alloc.allocation);
    }
}

gpu_host_to_device_ptr :: (host: *void) -> Gpu_Ptr {
    found, alloc := table_find(*allocations, host);
    if found {
        return alloc.gpu_ptr;
    }
    return 0;
}

#scope_file

Alloc_Info :: struct {
    allocation: VmaAllocation;
    gpu_ptr: Gpu_Ptr;
    type: Memory_Type;

    buffer: VkBuffer;
}

allocations: Table(*void, Alloc_Info);
gpu_allocations: Table(Gpu_Ptr, Alloc_Info);

#import "Hash_Table";