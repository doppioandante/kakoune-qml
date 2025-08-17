#ifndef KAKOUNE_CLIENT_H
#define KAKOUNE_CLIENT_H

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QVariant>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QKeyEvent>
#include <QProcess>


#include <QDebug>

class KakouneClient: public QObject
{
    Q_OBJECT
private:
    QProcess m_process;
    QByteArray m_buffer;
    QObject* m_kakounePane;

public:
    KakouneClient(const QString& session, QObject* component):
        m_kakounePane(component)
    {
        connect(&m_process, &QProcess::readyReadStandardOutput, component, [=] () {
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

        connect(&m_process, &QProcess::readyReadStandardError, component,  [=] () {
                qDebug() << "stderr: " << m_process.readAllStandardError();
        });

        connect(&m_process, SIGNAL(finished(int,QProcess::ExitStatus)), this, SIGNAL(subprocess_finished(int,QProcess::ExitStatus)));
        connect(component, SIGNAL(sendKeys(QString)), this, SLOT(rpc_keys(QString)));
        connect(component, SIGNAL(sendResize(int,int)), this, SLOT(rpc_resize(int,int)));
        connect(component, SIGNAL(sendScroll(int,int,int)), this, SLOT(rpc_scroll(int,int,int)));

        m_process.start("kak", {"-ui", "json", "-c", session});
    }

    ~KakouneClient()
    {
        m_process.close();
    }

signals:
    void subprocess_finished(int code, QProcess::ExitStatus);

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

    void rpc_scroll(int amount, int line, int column)
    {
        if (line >= 0 and column >= 0)
        {
            QJsonObject req{
                {{"jsonrpc", "2.0"}, {"method", "scroll"}, {"params", QJsonArray{amount}}}
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

#endif
