password = 'vagrant'

Veewee::Session.declare({
  :hostiocache => 'off',
  :cpu_count => '4',      # this can be changed afterwards in the Vagrantfile
  :memory_size=> '3072',  # this can be changed afterwards in the Vagrantfile
  :disk_size => '40560',  # this cannot be changed afterwards in the Vagrantfile!!
  :disk_format => 'VDI',
  :os_type_id => 'Gentoo_64', # for 32bit, change to 'Gentoo'
                         # from funtoo-latest_x86
#  :iso_file => "systemrescuecd-x86-3.0.0.iso",
#  :iso_src => "http://freefr.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/3.0.0/systemrescuecd-x86-3.0.0.iso",
#  :iso_md5 => "6bb6241af752b1d6dab6ae9e6e3e770e",
    # from funtoo-latest_generic                      
#  :iso_file => "install-amd64-minimal-20111208.iso",
#  :iso_src => "http://ftp.osuosl.org/pub/gentoo/releases/amd64/autobuilds/20111208/install-amd64-minimal-20111208.iso",
#  :iso_md5 => "8c4e10aaaa7cce35503c0d23b4e0a42a",
                         
  :iso_file => "install-amd64-minimal-20130110.iso",
  :iso_src => "http://mirror.switch.ch/ftp/mirror/gentoo/releases/amd64/autobuilds/20130110/install-amd64-minimal-20130110.iso",
  :iso_md5 => "67cfb094d159d7b359ea9797d636b6c7",

  :iso_download_timeout => "1000",
  :boot_wait => "4",
                         # *1 is for default option
                         #
                         # *46 for the de_CH keyboard
  :boot_cmd_sequence => [
        '<Wait>'*4,
        'gentoo-nofb<Enter>', # boot gentoo no frame buffer mode option
        '<Wait>'*20,
        '<Enter>',            # asks about your keyboard, take the default
        '<Wait>'*20,
        '<Enter><Wait>',      # just in case we are out of syncve
        'net-setup eth0<Enter>',
        '<Wait><Enter>',
        '2<Enter>',           # Set up the NIC card with DHCP
        '1<Enter>',
  '<Wait><Wait>ifconfig -a <Enter>',
        'passwd<Enter><Wait><Wait>',
  'vagrant<Enter><Wait>',
  'vagrant<Enter><Wait>',
        '/etc/init.d/sshd start<Enter><Wait><Wait>'
    ],
  :ssh_login_timeout => "10000",
  :ssh_user => "root",
  :ssh_password => password,
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "cat '%f'|su -",
  :shutdown_cmd => "shutdown -p now",
  :postinstall_files => ["postinstall.sh"],
  :postinstall_timeout => "15000"
})

