# Test for essential variables
[[ -z "$FREENAS_IP" ]] && { echo "Error: FREENAS_IP not set"; exit 1; } || echo "FREENAS_IP: ${FREENAS_IP}"
[[ -z "$FREENAS_BUDIR" ]] && { echo "Error: FREENAS_BUDIR not set"; exit 1; } || echo "FREENAS_BUDIR: ${FREENAS_BUDIR}"


# Update list of manually installed packages
# From: https://askubuntu.com/questions/2389/generating-list-of-manually-installed-packages-and-querying-individual-packages
PACKAGELOGFILE=~/pkgs_manually_installed_asof_$(date +%Y%m%d)
comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) > $PACKAGELOGFILE
echo -n "Backing up manually installed package list: "
wc -l $PACKAGELOGFILE

# backup from unix / linux to FreeNAS
# sudo apt-install nfs-common   # If NFS not installed for client machine
BACKUPMACH=$FREENAS_IP
# sudo mount -t nfs ${BACKUPMACH}:/mnt/TB2_Mirror/d_unix_files /mnt

# wget https://raw.githubusercontent.com/rubo77/rsync-homedir-excludes/master/rsync-homedir-excludes.txt -O /var/tmp/ignorelist

# perform Rsync
# rsync -aP --exclude-from=/var/tmp/ignorelist /home/$USER/ /media/$USER/linuxbackup/home/


# download to `rsync-homedir-local.txt`
wget https://raw.githubusercontent.com/djhejna/rsync-homedir-excludes/master/rsync-homedir-excludes.txt -O /tmp/rsync-homedir-local.txt
# or clone and copy to `rsync-homedir-local.txt`
git clone https://github.com/rubo77/rsync-homedir-excludes
cd rsync-homedir-excludes
cp rsync-homedir-excludes.txt rsync-homedir-local.txt

# edit the file rsync-homedir-local.txt to your needs
# nano rsync-homedir-local.txt
emacs -nw /tmp/rsync-homedir-local.txt

# define a Backup directory (with trailing slash!)
# some examples:
# BACKUPDIR=/media/workspace/home/$USER/
# BACKUPDIR=/media/$USER/linuxbackup/home/$USER/
# BACKUPDIR=/media/$USER/USBSTICK/backup/home/$USER/
BACKUPDIR=$FREENAS_BUDIR

BACKUPLOGFILE=/tmp/rsync_backup_$(date +%Y%m%d)

# first specify the "-n" parameter so rsync will simulate its operation. You should use this before you start:
echo "Test running rsync"  |& tee -a $BACKUPLOGFILE
rsync -naP --exclude-from=/tmp/rsync-homedir-local.txt /home/$USER/ root@$BACKUPMACH:$BACKUPDIR |& tee -a $BACKUPLOGFILE

# check for permission denied errors in your homedir:
echo "Test running rsync with grep denied"  |& tee -a $BACKUPLOGFILE
rsync -naP --exclude-from=/tmp/rsync-homedir-local.txt /home/$USER/ root@$BACKUPMACH:$BACKUPDIR|grep denied |& tee -a $BACKUPLOGFILE

echo "Test running rsync with grep error:"  |& tee -a $BACKUPLOGFILE
rsync -naP --exclude-from=/tmp/rsync-homedir-local.txt /home/$USER/ root@$BACKUPMACH:$BACKUPDIR|grep 'error:' |& tee -a $BACKUPLOGFILE

# if it is all fine, actually perform your backup:
rsync -aP --exclude-from=/tmp/rsync-homedir-local.txt /home/$USER/ root@$BACKUPMACH:$BACKUPDIR |& tee -a $BACKUPLOGFILE

