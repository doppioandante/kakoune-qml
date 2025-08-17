#pragma once

#include <QObject>
#include <QString>
#include <QList>
#include <qqml.h>
#include "kakoune_client.h"

class KakouneClientFactory: public QObject {
    Q_OBJECT
private:
    QString m_session;
    QList<KakouneClient*> m_clients;
public:
    KakouneClientFactory(QString session, QObject* parent = nullptr):
        QObject(parent),
        m_session(session)
    {}

    Q_INVOKABLE int addNewClient(QObject* component) {
        auto clt = new KakouneClient{m_session, component};
        int idx = m_clients.length();
        QObject::connect(
            clt, &KakouneClient::subprocess_finished,
            [=] {
                this->clientDisconnected(idx);
            });
        m_clients.append(clt);
        return true;
    }

signals:
    void noAliveClient(void);

private slots:
    void clientDisconnected(int idx) {
        delete m_clients.at(idx);
        m_clients.removeAt(idx); 
        if (m_clients.length() == 0) {
            emit noAliveClient();
        }
    }
};
