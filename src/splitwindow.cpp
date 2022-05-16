#include <iostream>
#include <cassert>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QProcess>

#include "kakoune_client.h"
#include "kakoune_server.h"
#include "kakoune_alive_client_counter.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine(QUrl("qrc:/splitmain.qml"));

    QObject* kakPaneLeft =
            engine.rootObjects().constFirst()->findChild<QObject*>("kakounePaneLeft");
    assert(kakPaneLeft != nullptr);
    QObject* kakPaneRight =
            engine.rootObjects().constFirst()->findChild<QObject*>("kakounePaneRight");
    assert(kakPaneRight != nullptr);

    KakouneServer srv{"kakouneqml"};
    KakouneClient clt1{"kakouneqml", kakPaneLeft};
    KakouneClient clt2{"kakouneqml", kakPaneRight};

    KakouneAliveClientCounter cnt{2};
    QObject::connect(&clt1, SIGNAL(subprocess_finished(int,QProcess::ExitStatus)), &cnt, SLOT(clientDisconnected()));
    QObject::connect(&clt2, SIGNAL(subprocess_finished(int,QProcess::ExitStatus)), &cnt, SLOT(clientDisconnected()));

    QObject::connect(&cnt, SIGNAL(noAliveClient(void)), &app, SLOT(quit()));
    return app.exec();
}
