#include <QObject>
#include <QString>
#include <QByteArray>
#include <QVariant>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QKeyEvent>
#include <QProcess>

#include <iostream>

#include <QDebug>

class KakouneClient: public QObject
{
    Q_OBJECT
private:
    QProcess m_process;
    QByteArray m_buffer;
    QObject* m_kakounePane;
    bool m_canWrite;

public:
    KakouneClient(const QString& session, QObject* component):
        m_kakounePane(component)
    {
        connect(&m_process, &QProcess::readyReadStandardOutput, [=] () {
              m_buffer.append(m_process.readAllStandardOutput());

              int last = 0;
              int lineSplit = m_buffer.indexOf("\n");
              while (lineSplit != -1)
              {
                  QMetaObject::invokeMethod(m_kakounePane, "processRpc", Q_ARG(QVariant, m_buffer.mid(last, lineSplit - last + 1)));
                  last = lineSplit + 1;
                  lineSplit = m_buffer.indexOf("\n", last);
              }

              m_buffer = m_buffer.mid(last);
        });

        connect(&m_process, &QProcess::readyReadStandardError, [=] () {
                qDebug() << "stderr: " << m_process.readAllStandardError();
        });

        connect(&m_process, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
            [=] (int code, QProcess::ExitStatus) {
            	qDebug() << "Process exited with code: " << code;
        });

        connect(component, SIGNAL(sendKey(QString)), this, SLOT(rpc_keys(QString)));
        connect(component, SIGNAL(sendResize(int, int)), this, SLOT(rpc_resize(int, int)));

        m_process.start("kak", {"-ui", "json"});
    }

    ~KakouneClient()
    {
        m_process.close();
    }

public slots:
    void rpc_keys(const QString &v)
    {
        QJsonObject req{
            {{"jsonrpc", "2.0"}, {"method", "keys"}, {"params", QJsonArray{v}}}
        };

        do_rpc_call(req);
    }

    void rpc_resize(int x, int y)
    {
        if (x > 0 and y > 0)
        {
            QJsonObject req{
                {{"jsonrpc", "2.0"}, {"method", "resize"}, {"params", QJsonArray{x, y}}}
            };

            do_rpc_call(req);
        }
    }

private:
    void do_rpc_call(QJsonObject req)
    {
        QByteArray rpc = QJsonDocument{req}.toJson(QJsonDocument::Compact);
        rpc.append('\n');
        m_process.write(rpc);
        m_process.waitForBytesWritten();
    }
};

