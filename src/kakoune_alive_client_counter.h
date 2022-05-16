#ifndef KAKOUNE_ALIVE_CLIENT_COUNTER_H
#define KAKOUNE_ALIVE_CLIENT_COUNTER_H

#include <QObject>

class KakouneAliveClientCounter: public QObject {
    Q_OBJECT
private:
    int m_count;
public:
    KakouneAliveClientCounter(int init):
        m_count(init)
    {}

signals:
    void noAliveClient(void);

public slots:
    void clientDisconnected(void) {
        if (m_count > 0) {
            m_count--;

            if (m_count == 0) {
                emit noAliveClient();
            }
        }
    }
};


#endif // KAKOUNE_ALIVE_CLIENT_COUNTER_H
