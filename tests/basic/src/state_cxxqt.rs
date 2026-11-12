#[cxx_qt::bridge]
mod qobject {
    extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qml_singleton]
        #[qproperty(i32, persistent_value, cxx_name = "persistentValue")]
        type RustSingleton = super::RustSingletonRust;

        /// Increment the persistent value Q_PROPERTY of the QML_SINGLETON
        #[qinvokable]
        fn increment(self: Pin<&mut Self>);

        #[qsignal]
        fn incremented_from_rust(self: Pin<&mut Self>);
    }
}

use core::pin::Pin;

/// A QObject which is a QML_SINGLETON
#[derive(Default)]
pub struct RustSingletonRust {
    /// A Q_PROPERTY with a persistent value
    persistent_value: i32,
}

impl qobject::RustSingleton {
    /// Increment the persistent value Q_PROPERTY of the QML_SINGLETON
    pub fn increment(self: Pin<&mut Self>) {
        let new_value = self.persistent_value() + 1;
        self.set_persistent_value(new_value);
    }
}
