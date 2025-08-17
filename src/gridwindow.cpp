#include <cassert>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QProcess>
#include <qqml.h>

#include "kakoune_server.h"
#include "kakoune_client_factory.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    KakouneServer srv{"kakouneqml"};
    KakouneClientFactory cltfactory{"kakouneqml"};

    QQmlApplicationEngine engine;
    qmlRegisterSingletonInstance("Kakoune.ClientFactory", 0, 1, "ClientFactory", &cltfactory); 

    engine.load(QUrl("qrc:/gridmain.qml"));
    QObject::connect(&cltfactory, SIGNAL(noAliveClient(void)), &app, SLOT(quit()));
    return app.exec();
}

