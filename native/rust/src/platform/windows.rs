//! Minimal OS-version gate for the Windows Rust migration scaffold.

use std::mem::size_of;

#[repr(C)]
struct RtlOsVersionInfoExW {
    dw_os_version_info_size: u32,
    dw_major_version: u32,
    dw_minor_version: u32,
    dw_build_number: u32,
    dw_platform_id: u32,
    sz_csd_version: [u16; 128],
    w_service_pack_major: u16,
    w_service_pack_minor: u16,
    w_suite_mask: u16,
    w_product_type: u8,
    w_reserved: u8,
}

#[link(name = "ntdll")]
extern "system" {
    fn RtlGetVersion(info: *mut RtlOsVersionInfoExW) -> i32;
}

/// Returns a user-facing Windows 10/11 label and build, rejecting Server editions.
pub fn detect_supported_client_os() -> Result<(&'static str, u32), String> {
    let mut info = RtlOsVersionInfoExW {
        dw_os_version_info_size: size_of::<RtlOsVersionInfoExW>() as u32,
        dw_major_version: 0,
        dw_minor_version: 0,
        dw_build_number: 0,
        dw_platform_id: 0,
        sz_csd_version: [0; 128],
        w_service_pack_major: 0,
        w_service_pack_minor: 0,
        w_suite_mask: 0,
        w_product_type: 0,
        w_reserved: 0,
    };

    let status = unsafe { RtlGetVersion(&mut info) };
    if status != 0 {
        return Err(format!("RtlGetVersion returned NTSTATUS 0x{:08X}", status as u32));
    }
    if info.w_product_type != 1 {
        return Err("Windows Server editions are not supported".to_string());
    }
    if info.dw_major_version != 10 || info.dw_minor_version != 0 || info.dw_build_number < 10_240 {
        return Err("unsupported Windows version".to_string());
    }

    if info.dw_build_number >= 22_000 {
        Ok(("Windows 11", info.dw_build_number))
    } else {
        Ok(("Windows 10", info.dw_build_number))
    }
}
