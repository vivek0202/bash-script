#!/bin/bash

dlq_cur='queuedepth | grep -v "=0|=" | grep -i IVAPP.PRD.S2WEB3.DlqService | tr -s " " " " | cut -d"=" -f2`
dlq_thr=4000

if [ $dlq_cur -gt $dlq_thr ];then
     echo "On IVAPP PROD WEB3 ['hostname'], Queue: IVAPP.PRD.S2WEB3.DlqService is at $dlq_cur ,Its above threshold value $dlq_thr' > /tmp/check_Dlqsvr.txt
     echo "" >> /tmp/check_Dlqsvr.txt
     echo "Please check and clear the queue" >> /tmp/check_Dlqsvr.txt
     echo "" >> /tmp/check_Dlqsvr.txt
     SUBJECT="ACTION REQUIRED : IVAPP.PRD.S2WEB3.DlqService Higher QDepth"
     #receipents=
     receipents=""
     /usr/sbin/sendemail -F "IVAPP.PRD.S2WEB3.DlqService Higher QDepth" $receipents <<EOF
     To: $receipents
     Subject:${SUBJECT}
     content-Type: text/html; charset="us-ascii"
     {text-decoration:none;}
     <pre>
     'cat /tmp/check_Dlqsvr.txt`
     </pre>
     EOF
     
     rm /tmp/check_Dlqsvr.txt > /dev/null 2>&1
     fi
     
     
     
     
     crontab -l |grep -i dlq
     0,10,20,30,40,50 * * * * . /home/vzpsadm/setbase; $BASE/sbin/serun $BASE/bin/DlqService_qchk.ksh
