import smtplib, ssl
from email.message import EmailMessage
from datetime import datetime


port = 465  # For SSL

# for easy switching smtp service
mail_service = ["gm","ndx"]

smtp_server = {"gm":"smtp.gmail.com", "ndx":"smtp.yandex.ru"}
sender_email = {"gm":"alphamtst@gmail.com", "ndx":"alphamtst@yandex.ru"}

login = {"gm":"alphamtst@gmail.com", "ndx":"alphamtst"}
password = {"gm":"Fyvapr123", "ndx":"pxsrvjgicwoipven"}



def mailer (receiver, ms_idx=1, message="Это тестовое сообщение"):
    email_msg = EmailMessage()
    email_msg.set_content(message+datetime.now().strftime("\n\nMessage was sent at %H:%M:%S"))

    email_msg['Subject'] ="Тест кириллицы"
    email_msg['From'] = sender_email[mail_service[ms_idx]]
    email_msg['To'] = receiver

    context = ssl.create_default_context()
    try:
        with smtplib.SMTP_SSL(smtp_server[mail_service[ms_idx]], port, context=context) as server:
            server.login(login[mail_service[ms_idx]], password[mail_service[ms_idx]])
            server.send_message(email_msg)
    except Exception as e:    
        return "Fail: "+str(e)
    else:
        return "Ok"

if __name__ == "__main__":
    print(mailer("alxminchuk@gmail.com"))
