#include <linux/module.h> // basic kernel module definitions
#include <linux/platform_device.h> // platform driver/device definitions
#include <linux/mod_devicetable.h> // of_device_id, MODULE_DEVICE_TABLE
#include <linux/io.h> // iowrite32/ioread32 functions
#include <linux/mutex.h> // mutex defintions
#include <linux/miscdevice.h> // miscdevice defintions
#include <linux/types.h> // data types like u32, u16, etc.
#include <linux/fs.h> // copy_to_user, etc.
#include <linux/kstrtox.h> // kstrtou8, etc.

#define duty_cycle_1_OFFSET 0x0
#define duty_cycle_2_OFFSET 0x04
#define duty_cycle_3_OFFSET 0x08
#define period_reg_OFFSET 0x10

#define SPAN 16


/**
* struct rgb_dev - Private <component> device struct.
* @base_addr: Pointer to the component's base address
* @<reg_name>: <reg_purpose>
* @miscdev: miscdevice used to create a character device
* @lock: mutex used to prevent concurrent writes to memory
*
* An rgb_dev struct gets created for each led patterns component.
*/
struct rgb_dev {
    void __iomem *base_addr;
    void __iomem *duty_cycle_1;
    void __iomem *duty_cycle_2;
    void __iomem *duty_cycle_3;
    void __iomem *period_reg;
    struct miscdevice miscdev;
    struct mutex lock;
};



/**
* duty_cycle_1_show() - Return the duty_cycle_1 value
* to user-space via sysfs.
* @dev: Device structure for the rgb component. This
* device struct is embedded in the rgb' device struct.
* @attr: Unused.
* @buf: Buffer that gets returned to user-space.
*
* Return: The number of bytes read.
*/
static ssize_t duty_cycle_1_show(struct device *dev,
struct device_attribute *attr, char *buf)
{
    u32 duty_cycle_1;
    struct rgb_dev *priv = dev_get_drvdata(dev);
    duty_cycle_1 = ioread32(priv->duty_cycle_1);
    return scnprintf(buf, PAGE_SIZE, "%u\n", duty_cycle_1);
}
/**
* duty_cycle_1_store() - Store the duty_cycle_1 value.
* @dev: Device structure for the rgb component. This
* device struct is embedded in the rgb
* platform device struct.
* @attr: Unused.
* @buf: Buffer that contains the stop_button value being written.
* @size: The number of bytes being written.
*
* Return: The number of bytes stored.
*/
static ssize_t duty_cycle_1_store(struct device *dev,
struct device_attribute *attr, const char *buf, size_t size)
{
    u32 duty_cycle_1;
    int ret;
    struct rgb_dev *priv = dev_get_drvdata(dev);
    // Parse the string we received as an unsigned 32-bit int
    // See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L289
    ret = kstrtouint(buf, 0, &duty_cycle_1);
    if (ret < 0) 
    {
        return ret;
    }
    iowrite32(duty_cycle_1, priv->duty_cycle_1);
    // Write was successful, so we return the number of bytes we wrote.
    return size;
}




/**
* duty_cycle_2_show() - Return the duty_cycle_2 value
* to user-space via sysfs.
* @dev: Device structure for the rgb component. This
* device struct is embedded in the rgb' device struct.
* @attr: Unused.
* @buf: Buffer that gets returned to user-space.
*
* Return: The number of bytes read.
*/
static ssize_t duty_cycle_2_show(struct device *dev,
struct device_attribute *attr, char *buf)
{
    u32 duty_cycle_2;
    struct rgb_dev *priv = dev_get_drvdata(dev);
    duty_cycle_2 = ioread32(priv->duty_cycle_2);
    return scnprintf(buf, PAGE_SIZE, "%u\n", duty_cycle_2);
}
/**
* duty_cycle_2_store() - Store the duty_cycle_2 value.
* @dev: Device structure for the rgb component. This
* device struct is embedded in the rgb
* platform device struct.
* @attr: Unused.
* @buf: Buffer that contains the stop_button value being written.
* @size: The number of bytes being written.
*
* Return: The number of bytes stored.
*/
static ssize_t duty_cycle_2_store(struct device *dev,
struct device_attribute *attr, const char *buf, size_t size)
{
    u32 duty_cycle_2;
    int ret;
    struct rgb_dev *priv = dev_get_drvdata(dev);
    // Parse the string we received as an unsigned 32-bit int
    // See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L289
    ret = kstrtouint(buf, 0, &duty_cycle_2);
    if (ret < 0) 
    {
        return ret;
    }
    iowrite32(duty_cycle_2, priv->duty_cycle_2);
    // Write was successful, so we return the number of bytes we wrote.
    return size;
}



/**
* duty_cycle_3_show() - Return the duty_cycle_3 value
* to user-space via sysfs.
* @dev: Device structure for the rgb component. This
* device struct is embedded in the rgb' device struct.
* @attr: Unused.
* @buf: Buffer that gets returned to user-space.
*
* Return: The number of bytes read.
*/
static ssize_t duty_cycle_3_show(struct device *dev,
struct device_attribute *attr, char *buf)
{
    u32 duty_cycle_3;
    struct rgb_dev *priv = dev_get_drvdata(dev);
    duty_cycle_3 = ioread32(priv->duty_cycle_3);
    return scnprintf(buf, PAGE_SIZE, "%u\n", duty_cycle_3);
}
/**
* duty_cycle_3_store() - Store the duty_cycle_3 value.
* @dev: Device structure for the rgb component. This
* device struct is embedded in the rgb
* platform device struct.
* @attr: Unused.
* @buf: Buffer that contains the stop_button value being written.
* @size: The number of bytes being written.
*
* Return: The number of bytes stored.
*/
static ssize_t duty_cycle_3_store(struct device *dev,
struct device_attribute *attr, const char *buf, size_t size)
{
    u32 duty_cycle_3;
    int ret;
    struct rgb_dev *priv = dev_get_drvdata(dev);
    // Parse the string we received as an unsigned 32-bit int
    // See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L289
    ret = kstrtouint(buf, 0, &duty_cycle_3);
    if (ret < 0) {
    return ret;
    }
    iowrite32(duty_cycle_3, priv->duty_cycle_3);
    // Write was successful, so we return the number of bytes we wrote.
    return size;
}


/**
* period_reg_show() - Return the period_reg value
* to user-space via sysfs.
* @dev: Device structure for the rgb component. This
* device struct is embedded in the rgb' device struct.
* @attr: Unused.
* @buf: Buffer that gets returned to user-space.
*
* Return: The number of bytes read.
*/
static ssize_t period_reg_show(struct device *dev,
struct device_attribute *attr, char *buf)
{
    u32 period_reg;
    struct rgb_dev *priv = dev_get_drvdata(dev);
    period_reg = ioread32(priv->period_reg);
    return scnprintf(buf, PAGE_SIZE, "%u\n", period_reg);
}
/**
* period_reg_store() - Store the period_reg value.
* @dev: Device structure for the rgb component. This
* device struct is embedded in the rgb
* platform device struct.
* @attr: Unused.
* @buf: Buffer that contains the stop_button value being written.
* @size: The number of bytes being written.
*
* Return: The number of bytes stored.
*/
static ssize_t period_reg_store(struct device *dev,
struct device_attribute *attr, const char *buf, size_t size)
{
    u32 period_reg;
    int ret;
    struct rgb_dev *priv = dev_get_drvdata(dev);
    // Parse the string we received as an unsigned 32-bit int
    // See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L289
    ret = kstrtouint(buf, 0, &period_reg);
    if (ret < 0) {
    return ret;
    }
    iowrite32(period_reg, priv->period_reg);
    // Write was successful, so we return the number of bytes we wrote.
    return size;
}

// Define sysfs attributes
static DEVICE_ATTR_RW(duty_cycle_1);
static DEVICE_ATTR_RW(duty_cycle_2);
static DEVICE_ATTR_RW(duty_cycle_3);
static DEVICE_ATTR_RW(period_reg);

// Create an attribute group so the device core can
// export the attributes for us.
static struct attribute *rgb_attrs[] = {
    &dev_attr_duty_cycle_1.attr,
    &dev_attr_duty_cycle_2.attr,
    &dev_attr_duty_cycle_3.attr,
    &dev_attr_period_reg.attr,
    NULL,
};
ATTRIBUTE_GROUPS(rgb);


/**
* rgb_read() - Read method for the rgb char device
* @file: Pointer to the char device file struct.
* @buf: User-space buffer to read the value into.
* @count: The number of bytes being requested.
* @offset: The byte offset in the file being read from.
*
* Return: On success, the number of bytes written is returned and the
* offset @offset is advanced by this number. On error, a negative error
* value is returned.
*/
static ssize_t rgb_read(struct file *file, char __user *buf,
size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;
    /*
    * Get the device's private data from the file struct's private_data
    * field. The private_data field is equal to the miscdev field in the
    * rgb_dev struct. container_of returns the
    * rgb_dev struct that contains the miscdev in private_data.
    */
    struct rgb_dev *priv = container_of(file->private_data,
    struct rgb_dev, miscdev);
    // Check file offset to make sure we are reading from a valid location.
    if (*offset < 0) 
    {
        // We can't read from a negative file position.
        return -EINVAL;
    }
    if (*offset >= SPAN) 
    {
        // We can't read from a position past the end of our device.
        return 0;
    }
    if ((*offset % 0x4) != 0) 
    {
        // Prevent unaligned access.
        pr_warn("rgb_read: unaligned access\n");
        return -EFAULT;
    }
    val = ioread32(priv->base_addr + *offset);
    // Copy the value to userspace.
    ret = copy_to_user(buf, &val, sizeof(val));
    if (ret == sizeof(val)) 
    {
        pr_warn("rgb_read: nothing copied\n");
        return -EFAULT;
    }
    // Increment the file offset by the number of bytes we read.
    *offset = *offset + sizeof(val);
    return sizeof(val);
}
/**
* rgb_write() - Write method for the rgb char device
* @file: Pointer to the char device file struct.
* @buf: User-space buffer to read the value from.
* @count: The number of bytes being written.
* @offset: The byte offset in the file being written to.
*
* Return: On success, the number of bytes written is returned and the
* offset @offset is advanced by this number. On error, a negative error
File Operations: Defines operations supported by the device driver.
Probe and Remove: These are called when the device driver is loaded into the kernel. Make sure to add in registers
with their offsets where indicated!
* value is returned.
*/
static ssize_t rgb_write(struct file *file, const char __user *buf,
size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;
    struct rgb_dev *priv = container_of(file->private_data,
    struct rgb_dev, miscdev);
    if (*offset < 0) 
    {
        return -EINVAL;
    }
    if (*offset >= SPAN) {
        return 0;
    }
    if ((*offset % 0x4) != 0) {
    pr_warn("rgb_write: unaligned access\n");
        return -EFAULT;
    }
    mutex_lock(&priv->lock);
    // Get the value from userspace.
    ret = copy_from_user(&val, buf, sizeof(val));
    if (ret != sizeof(val)) 
    {
        iowrite32(val, priv->base_addr + *offset);
        // Increment the file offset by the number of bytes we wrote.
        *offset = *offset + sizeof(val);
        // Return the number of bytes we wrote.
        ret = sizeof(val);
    }
    else 
    {
        pr_warn("rgb_write: nothing copied from user space\n");
        ret = -EFAULT;
    }
    mutex_unlock(&priv->lock);
    return ret;
}



/**
* rgb_fops - File operations supported by the
* rgb driver
* @owner: The rgb driver owns the file operations; this
* ensures that the driver can't be removed while the
* character device is still in use.
* @read: The read function.
* @write: The write function.
* @llseek: We use the kernel's default_llseek() function; this allows
* users to change what position they are writing/reading to/from.
*/
static const struct file_operations rgb_fops = {
    .owner = THIS_MODULE,
    .read = rgb_read,
    .write = rgb_write,
    .llseek = default_llseek,
};





static int rgb_probe(struct platform_device *pdev)
{
    size_t ret;
    struct rgb_dev *priv;
    /*
    * Allocate kernel memory for the rgb device and set it to 0.
    * GFP_KERNEL specifies that we are allocating normal kernel RAM;
    * see the kmalloc documentation for more info. The allocated memory
    * is automatically freed when the device is removed.
    */
    priv = devm_kzalloc(&pdev->dev, sizeof(struct rgb_dev),
    GFP_KERNEL);
    if (!priv) 
    {
        pr_err("Failed to allocate memory\n");
        return -ENOMEM;
    }
    /*
    * Request and remap the device's memory region. Requesting the region
    * make sure nobody else can use that memory. The memory is remapped
    * into the kernel's virtual address space because we don't have access
    * to physical memory locations.
    */
    priv->base_addr = devm_platform_ioremap_resource(pdev, 0);
    if (IS_ERR(priv->base_addr)) 
    {
        pr_err("Failed to request/remap platform device resource\n");
        return PTR_ERR(priv->base_addr);
    }
    // Set the memory addresses for each register.
    priv->duty_cycle_1 = priv->base_addr + duty_cycle_1_OFFSET;
    priv->duty_cycle_2 = priv->base_addr + duty_cycle_2_OFFSET;
    priv->duty_cycle_3 = priv->base_addr + duty_cycle_3_OFFSET;
    priv->period_reg = priv->base_addr + period_reg_OFFSET;
    // Do any initializations when module is loaded
    //iowrite32(<value>, priv-><reg_name>);
    // Initialize the misc device parameters
    priv->miscdev.minor = MISC_DYNAMIC_MINOR;
    priv->miscdev.name = "rgb";
    priv->miscdev.fops = &rgb_fops;
    priv->miscdev.parent = &pdev->dev;
    // Register the misc device; this creates a char dev at /dev/rgb
    ret = misc_register(&priv->miscdev);
    if (ret) 
    {
        pr_err("Failed to register misc device");
        return ret;
    }
    /* Attach the rgb's private data to the platform device's struct.
    * This is so we can access our state container in the other functions.
    */
    platform_set_drvdata(pdev, priv);
    pr_info("rgb_probe successful\n");
    return 0;
}
/**
* rgb_remove() - Remove an rgb device.
* @pdev: Platform device structure associated with our rgb device.
*
* This function is called when an rgb devicee is removed or
* the driver is removed.
*/
static int rgb_remove(struct platform_device *pdev)
{
    // Get the rgb's private data from the platform device.
    struct rgb_dev *priv = platform_get_drvdata(pdev);
    // Any writes to do when the module is removed
    //iowrite32(0x0, priv-><reg_name>);
    // Deregister the misc device and remove the /dev/led_patterns file.
    misc_deregister(&priv->miscdev);
    pr_info("rgb_remove successful\n");
    return 0;
}


/*
* Define the compatible property used for matching devices to this driver,
* then add our device id structure to the kernel's device table. For a device
* to be matched with this driver, its device tree node must use the same
* compatible string as defined here.
*/
static const struct of_device_id rgb_of_match[] = {
    { .compatible = "joshcolter,rgb", },
    { }
};

MODULE_DEVICE_TABLE(of, rgb_of_match);
/*
* struct rgb_driver - Platform driver struct for the rgb driver
* @probe: Function that's called when a device is found
* @remove: Function that's called when a device is removed
* @driver.owner: Which module owns this driver
* @driver.name: Name of the pwm_rgb driver
* @driver.of_match_table: Device tree match table
*/
static struct platform_driver rgb_driver = {
    .probe = rgb_probe,
    .remove = rgb_remove,
    .driver = {
    .owner = THIS_MODULE,
    .name = "rgb",
    .of_match_table = rgb_of_match,
    .dev_groups = rgb_groups,
    },
};
/*
* We don't need to do anything special in module init/exit.
* This macro automatically handles module init/exit.
*/
module_platform_driver(rgb_driver);
MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Joshua Colter");
MODULE_DESCRIPTION("rgb driver");