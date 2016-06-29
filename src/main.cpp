#include <iostream>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "kakoune_client.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine(QUrl("qrc:/boson.qml"));

    QObject* kakPane = engine.rootObjects()[0]->children()[0];

    KakouneClient clt{"boson", kakPane};

    return app.exec();
}
