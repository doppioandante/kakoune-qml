#ifndef KAKOUNE_SERVER_H
#define KAKOUNE_SERVER_H

#include <QObject>
#include <QProcess>

class KakouneServer: public QObject
{
    Q_OBJECT
private:
    QProcess m_process;

public:
    KakouneServer(const QString& sessionName)
    {
        connect(&m_process,
                SIGNAL(finished(int,QProcess::ExitStatus)),
                this,
                SIGNAL(subprocess_finished(int,QProcess::ExitStatus)));

        m_process.start("kak", {"-d", "-s", sessionName});
    }

    ~KakouneServer()
    {
        m_process.kill();
        m_process.close();
    }

signals:
    void subprocess_finished(int code, QProcess::ExitStatus);
};


#endif // KAKOUNE_SERVER_H
