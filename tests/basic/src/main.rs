use std::{cell::RefCell, rc::Rc, time::Duration};

use qtbridge::{QApp, QmlObject, qobject};

#[derive(Default)]
pub struct Backend {
    counter: u64,
    inner: Rc<RefCell<NestedObject>>,
}

#[derive(Default)]
pub struct NestedObject {
    msg: String,
    inner: Rc<RefCell<OtherNestedObject>>,
}

#[derive(Default)]
pub struct OtherNestedObject {
    msg: String,
}

#[qobject]
impl NestedObject {
    qproperty!("msg", Member = msg, Constant);
    qproperty!("inner", Member = inner, Constant);
}

#[qobject]
impl OtherNestedObject {
    qproperty!("msg", Member = msg, Constant);
}

#[qobject(Singleton)]
impl Backend {
    qproperty!(
        "counter",
        Member = counter,
        Write = set_counter,
        Notify = counter_changed
    );

    qproperty!("inner", Member = inner, Notify = inner_changed);

    #[qslot]
    fn say_hello(&self) {
        println!("Hello world!");
    }

    fn set_counter(&mut self, value: u64) {
        self.counter = value;
        self.counter_changed();
    }

    #[qsignal]
    fn counter_changed(&mut self);

    #[qsignal]
    fn inner_changed(&mut self);

    #[qslot]
    fn register(&mut self) {
        let handle = self.get_thread_handle();

        std::thread::spawn(move || {
            let mut count = 0;
            loop {
                std::thread::sleep(Duration::from_secs(1));
                count += 1;

                handle.invoke_mut(move |this| {
                    this.set_counter(count);
                });
            }
        });
    }
}

fn main() {
    QApp::new()
        .register::<Backend>()
        .load_qml_from_file("qrc:/qt/qml/com/ui/components/qml/main.qml")
        .run();
}
