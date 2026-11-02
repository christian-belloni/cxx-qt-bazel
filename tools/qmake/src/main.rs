use std::{collections::HashMap, path::PathBuf};

fn main() {
    let mut args = std::env::args();
    let mut vars = HashMap::new();

    let binding = PathBuf::from(std::env::var("LIB_DIR").unwrap());
    let prefix = binding.parent().unwrap();
    let qt_dir = prefix.display();

    vars.insert("QT_INSTALL_PREFIX", format!("{qt_dir}"));
    vars.insert("QT_INSTALL_ARCHDATA", format!("{qt_dir}"));
    vars.insert("QT_INSTALL_DATA", format!("{qt_dir}"));
    vars.insert("QT_INSTALL_DOCS", format!("{qt_dir}/doc"));
    vars.insert("QT_INSTALL_HEADERS", format!("{qt_dir}/include"));
    vars.insert("QT_INSTALL_LIBS", format!("{qt_dir}/lib"));
    vars.insert("QT_INSTALL_LIBEXECS", format!("{qt_dir}/libexec"));
    vars.insert("QT_INSTALL_BINS", format!("{qt_dir}/bin"));
    vars.insert("QT_INSTALL_TESTS", format!("{qt_dir}/tests"));
    vars.insert("QT_INSTALL_PLUGINS", format!("{qt_dir}/plugins"));
    vars.insert("QT_INSTALL_QML", format!("{qt_dir}/qml"));
    vars.insert("QT_INSTALL_TRANSLATIONS", format!("{qt_dir}/translations"));
    vars.insert("QT_INSTALL_EXAMPLES", format!("{qt_dir}/examples"));
    vars.insert("QT_INSTALL_DEMOS", format!("{qt_dir}/examples"));
    vars.insert("QT_HOST_PREFIX", format!("{qt_dir}"));
    vars.insert("QT_HOST_DATA", format!("{qt_dir}"));
    vars.insert("QT_HOST_BINS", format!("{qt_dir}/bin"));
    vars.insert("QT_HOST_LIBEXECS", format!("{qt_dir}/libexec"));
    vars.insert("QT_HOST_LIBS", format!("{qt_dir}/lib"));
    vars.insert("QT_VERSION", "6.12.0".into());
    args.next();

    match (args.next(), args.next()) {
        (Some(_), Some(var)) => {
            println!("{}", vars.get(&*var).unwrap());
        }
        (Some(_), None) => {
            println!("QMAKE_SPEC:win32-g++");
            println!("QT_SYSROOT:");
            for (k, v) in vars {
                println!("{}:{}", k, v);
            }
            println!("QMAKE_SPEC:macx-clang");
            println!("QMAKE_XSPEC:macx-clang");
            println!("QMAKE_VERSION:3.1");
        }
        _ => {}
    }
}
