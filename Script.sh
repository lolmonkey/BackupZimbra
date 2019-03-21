#!/bin/bash

#Delete /tmp backup
rm -rf /tmp/zmigrate

#Move existing backup to /tmp
mv /backups/* /tmp


#Create folder for backup and granted to user zimbra
mkdir -p /backups/zmigrate
chown zimbra.zimbra /backups/zmigrate

#Change to backup folder
cd /backups/zmigrate

#Take all domains
sudo -u zimbra /opt/zimbra/bin/zmprov gad > domains.txt

echo "#######################
$(cat domains.txt)
########################

Domains has beed saved"

#Take all admin domain
sudo -u zimbra /opt/zimbra/bin/zmprov gaaa > admins.txt

echo "

########################
$(cat admins.txt)
#########################


admins account has been saved


Processing to saving email address begin . . . . . .
"

#Backup email address
sudo -u zimbra /opt/zimbra/bin/zmprov -l gaa > originemails.txt

#Delete galsync, spam, virus email address
egrep -i -v "^galsync|^spam|^virus" /backups/zmigrate/originemails.txt > /backups/zmigrate/emails.txt

echo "
Email address has been saved"

#Backup Distribution List
sudo -u zimbra /opt/zimbra/bin/zmprov gadl > distributionlist.txt


echo "
##########################################

$(cat distributionlist.txt)


#########################################


Distribution List has been saved

"

#Backup user distribution list
mkdir /backups/zmigrate/distributionlist_member
chown zimbra.zimbra /backups/zmigrate/distributionlist_member

for i in `cat /backups/zmigrate/distributionlist.txt`; do /opt/zimbra/bin/zmprov gdlm $i > /backups/zmigrate/distributionlist_member/$i.txt ;echo "$i";done

mkdir /backups/zmigrate/userpass
chown zimbra.zimbra /backups/zmigrate/userpass

#Backup password user
for i in `cat emails.txt`; do /opt/zimbra/bin/zmprov -l ga $i userPassword |grep userPassword: | awk '{ print $2}' > userpass/$i.shadow; echo "user $i password has been backed up" ; done


#Create folder for alias
mkdir -p /backups/zmigrate/alias

#Granted those folder to zimbra
chown zimbra.zimbra /backups/zmigrate/alias

#Backup alias 
for i in `cat emails.txt`; do /opt/zimbra/bin/zmprov ga  $i | grep zimbraMailAlias |awk '{print $2}' > alias/$i.txt ;echo $i ;done

#Detele account that hasnt alias
find alias/ -type f -empty | xargs -n1 rm -v


#Backup Forwarding
for account in `cat /backups/zmigrate/emails.txt`; do
forwardingaddress=`zmprov ga $account |grep 'zimbraPrefMailForwardingAddress' |sed 's/zimbraPrefMailForwardingAddress: //'`
if [ "$forwardingaddress" != "" ]; then
echo "$account is forwarding to $forwardingaddress" > forwarding.txt
else
forwardingaddress=""
echo "$account didnt have forwarding address" 
fi
done
