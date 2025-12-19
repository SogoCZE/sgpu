TEXTURE_BINDING :: 0;
RW_TEXTURE_BINDING :: 1;


#scope_module

create_descriptor_buffer :: () {
    descriptor_properties: VkPhysicalDeviceDescriptorBufferPropertiesEXT;
    properties: VkPhysicalDeviceProperties2;
    properties.pNext = *descriptor_properties;
    vkGetPhysicalDeviceProperties2(vk_physical_device, *properties);

    num_sampled_images := min(properties.properties.limits.maxDescriptorSetSampledImages, MAX_IMAGES);
    num_storage_images := min(properties.properties.limits.maxDescriptorSetStorageImages, MAX_IMAGES);

    bindings := VkDescriptorSetLayoutBinding.[
        .{
            binding = TEXTURE_BINDING,
            descriptorType = .SAMPLED_IMAGE,
            descriptorCount = num_sampled_images,
            stageFlags = .ALL,
        },
        .{
            binding = RW_TEXTURE_BINDING,
            descriptorType = .STORAGE_IMAGE,
            descriptorCount = num_storage_images,
            stageFlags = .ALL,
        }
    ];

    create_info := VkDescriptorSetLayoutCreateInfo.{
        flags = .DESCRIPTOR_BUFFER_BIT_EXT,
        bindingCount = bindings.count.(u32),
        pBindings = bindings.data
    };


    vk_result := vkCreateDescriptorSetLayout(vk_device, *create_info, null, *bindless_set_layout);
    assert_vk_result(vk_result);
}


bindless_set_layout: VkDescriptorSetLayout;