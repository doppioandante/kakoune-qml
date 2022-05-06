#include <iostream>
#include <cassert>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QProcess>

#include "kakoune_client.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine(QUrl("qrc:/mainwindow.qml"));

    QObject* kakPane = engine.rootObjects().constFirst()->findChild<QObject*>("kakounePane");
    assert(kakPane != nullptr);

    KakouneClient clt{"kakouneqml", kakPane};
    QObject::connect(&clt, SIGNAL(subprocess_finished(int,QProcess::ExitStatus)), &app, SLOT(quit()));
    return app.exec();
}
