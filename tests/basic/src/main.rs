use qtbridge::{QApp, qobject};

#[derive(Default)]
pub struct Backend {}

#[qobject(Singleton)]
impl Backend {
    #[qslot]
    fn say_hello(&self) {
        println!("Hello world!");
    }
}

fn main() {
    QApp::new()
        .register::<Backend>()
        .load_qml_from_file("qrc:/qt/qml/com/ui/components/qml/main.qml")
        .run();
}
