#include <QtGui>
#include <QtQml>
#include <QMetaType>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine("qrc:/qt/qml/ui/qml/main.qml");
    return app.exec();
}
