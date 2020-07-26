
# Update list of manually installed packages
# From: https://askubuntu.com/questions/2389/generating-list-of-manually-installed-packages-and-querying-individual-packages
PACKAGELOGFILE=~/pkgs_manually_installed_asof_$(date +%Y%m%d)
comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) > $PACKAGELOGFILE
echo -n "Backing up manually installed package list: "
wc -l $PACKAGELOGFILE


# comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) > /tmp/manual-list-1.txt
# comm -23 <(aptitude search '~i !~M' -F '%p' | sed "s/ *$//" | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u) > /tmp/manual-list-2.txt
