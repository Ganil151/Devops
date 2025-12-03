### Install the required packages:
```sh
sudo dnf update 

sudo dnf install -y openscap-scanner scap-security-guide

# Verify the installation:
 
   oscap --version
   

# (Optional) Install additional tools:
   sudo dnf install -y openscap-utils
  
```
#### Pull Oscap file 
```sh
# centos8
oscap info /usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml

# rhel8
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
```

 Can we run a report?
#### Profile Syntax
```sh
sudo oscap xccdf eval \ 
--profile <profile_id> \ 
--results <results_file.xml> \ 
--report <report_file.html> \
<path_to_scap_datastream_file>
```
#### Baseline Profile
```sh
sudo oscap xccdf eval \
--profile xccdf_org.ssgproject.content_profile_cis \
--results /tmp/baseline_results.xml \
--report /tmp/baseline_report.html \
/usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

# CentOS Stream 9
sudo oscap xccdf eval \
--profile xccdf_org.ssgproject.content_profile_cis \
--results /tmp/baseline_results.xml \
--report /tmp/baseline_report.html \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
```
##### OSPP Profile
```bash
sudo oscap xccdf eval \
--profile xccdf_org.ssgproject.content_profile_ospp \
--results /tmp/ospp_results.xml \
--report /tmp/ospp_report.html \
/usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

# CentOS Stream 9
sudo oscap xccdf eval \
--profile xccdf_org.ssgproject.content_profile_ospp \
--results /tmp/ospp_results.xml \
--report /tmp/ospp_report.html \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
```

`first scan gives “notapplicable”`
#### Now do this…
```sh
sudo cp /usr/share/openscap/cpe/openscap-cpe-dict.xml /usr/share/openscap/cpe/openscap-cpe-dict.xml.dist
sudo cp /usr/share/openscap/cpe/openscap-cpe-oval.xml /usr/share/openscap/cpe/openscap-cpe-oval.xml.dist
sudo curl -L https://raw.githubusercontent.com/OpenSCAP/openscap/maint-1.3/cpe/openscap-cpe-dict.xml -o /usr/share/openscap/cpe/openscap-cpe-dict.xml
sudo curl -L https://raw.githubusercontent.com/OpenSCAP/openscap/maint-1.3/cpe/openscap-cpe-oval.xml -o /usr/share/openscap/cpe/openscap-cpe-oval.xml
```
#### Does it work yet?
```sh
sudo oscap xccdf eval \
--profile xccdf_org.ssgproject.content_profile_cis \
--results /tmp/results.xml \
--report /tmp/report.html \
/usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

# CentOS Stream 9
sudo oscap xccdf eval \
--profile xccdf_org.ssgproject.content_profile_cis \
--results /tmp/results.xml \
--report /tmp/report.html \
/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
```
Still no…
#### Now do this…
```sh
sudo sed -i \
  -e 's|idref="cpe:/o:redhat:enterprise_linux|idref="cpe:/o:centos:centos|g' \
  -e 's|ref_id="cpe:/o:redhat:enterprise_linux|ref_id="cpe:/o:centos:centos|g' \
  /usr/share/xml/scap/ssg/content/ssg-rhel*.xml

# CentOS Stream 9
sudo sed -i \
  -e 's|idref="cpe:/o:redhat:enterprise_linux|idref="cpe:/o:centos:centos|g' \
  -e 's|ref_id="cpe:/o:redhat:enterprise_linux|ref_id="cpe:/o:centos:centos|g' \
  /usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml
```
It replaces<font color="#ffff00"> redhat:enterprise</font> with <font color="#ffff00">centos:centos</font>
Now it works!
#### List all the different profiles available:
```sh
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
```
#### Run the report to check against the CIS benchmark:
```sh
sudo oscap xccdf eval \
--profile xccdf_org.ssgproject.content_profile_cis \
--results /tmp/results.xml \
--report /tmp/report.html \
/usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
```

 Check the report.

### Fix the Failed Result 

#### Identify the Result ID
```sh
oscap info /tmp/results.xml | grep "Result ID"

# Result ID: xccdf_org.open-scap_testresult_xccdf_org.ssgproject.content_profile_cis
```
#### Generate Fix
`oscap xccdf generate fix` command to create a bash script that will attempt to fix the failed rules:
```sh
sudo oscap xccdf generate fix \
--fix-type bash \
--output /tmp/cis_remediation.sh \
--result-id xccdf_org.open-scap_testresult_xccdf_org.ssgproject.content_profile_cis \
/tmp/cis_results.xml
```
#### Fix After Remediation
Comment out: audit rules 11, 135 and 137
```sh
# ###############################################################################

# # BEGIN fix (11 / 197) for 'xccdf_org.ssgproject.content_rule_package_gdm_removed'

# ###############################################################################

# (>&2 echo "Remediating rule 11/197: 'xccdf_org.ssgproject.content_rule_package_gdm_removed'"); (

# # Remediation is applicable only in certain platforms

# if rpm --quiet -q gdm; then

  

# # CAUTION: This remediation script will remove gdm

# #    from the system, and may remove any packages

# #    that depend on gdm. Execute this

# #    remediation AFTER testing on a non-production

# #    system!

  

# if rpm -q --quiet "gdm" ; then

# dnf remove -y --noautoremove "gdm"

# fi

  

# else

#     >&2 echo 'Remediation is not applicable, nothing was done'

# fi

  

# ) # END fix for 'xccdf_org.ssgproject.content_rule_package_gdm_removed'

###############################################################################

# BEGIN fix (135 / 197) for 'xccdf_org.ssgproject.content_rule_package_xorg-x11-server-common_removed'

###############################################################################

# (>&2 echo "Remediating rule 135/197: 'xccdf_org.ssgproject.content_rule_package_xorg-x11-server-common_removed'"); (

  

# # CAUTION: This remediation script will remove xorg-x11-server-common

# #    from the system, and may remove any packages

# #    that depend on xorg-x11-server-common. Execute this

# #    remediation AFTER testing on a non-production

# #    system!

  

# if rpm -q --quiet "xorg-x11-server-common" ; then

# dnf remove -y --noautoremove "xorg-x11-server-common"

# fi

  

# ) # END fix for 'xccdf_org.ssgproject.content_rule_package_xorg-x11-server-common_removed'

  

# ###############################################################################

# # BEGIN fix (136 / 197) for 'xccdf_org.ssgproject.content_rule_xwindows_runlevel_target'

# ###############################################################################

# (>&2 echo "Remediating rule 136/197: 'xccdf_org.ssgproject.content_rule_xwindows_runlevel_target'"); (

# # Remediation is applicable only in certain platforms

# if rpm --quiet -q kernel; then

  

# systemctl set-default multi-user.target

  

# else

#     >&2 echo 'Remediation is not applicable, nothing was done'

# fi

  

# ) # END fix for 'xccdf_org.ssgproject.content_rule_xwindows_runlevel_target'
```
If not reinstall gdm
```sh
sudo dnf groupinstall "Server with GUI" -y
sudo systemctl enable gdm
sudo systemctl set-default graphical.target
sudo systemctl start gdm
sudo reboot
```

### OpenSCAP : Install2022/07/01

|     |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     | Install OpenSCAP which is the security audit and vulnerability scanning tool based on SCAP (Security Content Automation Protocol).<br><br>For details about SCAP, refer to the site below.  <br>⇒ https://csrc.nist.gov/projects/security-content-automation-protocol<br><br>OVAL  (Open Vulnerability and Assessment Language)<br><br>XCCDF (Extensible Configuration Checklist Description Format)<br><br>OCIL  (Open Checklist Interactive Language)<br><br>CPE   (Common Platform Enumeration)<br><br>CCE   (Common Configuration Enumeration)<br><br>CVE   (Common Vulnerabilities and Exposures)<br><br>CVSS  (Common Vulnerability Scoring System) |
| [1] | Install OpenSCAP command line tool and SCAP Security Guide for Linux.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |

|   |
|---|
|[root@dlp ~]# <br><br>[dnf](https://www.server-world.info/en/command/html/dnf.html) -y install openscap-scanner scap-security-guide|

|   |   |
|---|---|
|[2]|SCAP Security Guide is installed under the [/usr/share/xml/scap/ssg/content] directory.|

|                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [root@dlp ~]# <br><br>[ll](https://www.server-world.info/en/command/html/ls.html) /usr/share/xml/scap/ssg/content/<br><br>  <br><br>total 41804<br>-rw-r--r--. 1 root root 21300553 Jun  2 00:13 ssg-cs9-ds.xml<br>-rw-r--r--. 1 root root 21502789 Jun  2 00:13 ssg-rhel9-ds.xml<br><br># display description for each content<br><br>  <br>[root@dlp ~]# <br><br>oscap info /usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml<br><br>  <br><br>Document type: Source Data Stream<br>Imported: 2022-06-02T00:13:16<br><br>Stream: scap_org.open-scap_datastream_from_xccdf_ssg-rhel9-xccdf-1.2.xml<br>Generated: (null)<br>Version: 1.3<br>Checklists:<br>        Ref-Id: scap_org.open-scap_cref_ssg-rhel9-xccdf-1.2.xml<br>                Status: draft<br>                Generated: 2022-06-01<br>                Resolved: true<br>                Profiles:<br>                        Title: ANSSI-BP-028 (enhanced)<br>                                Id: xccdf_org.ssgproject.content_profile_anssi_bp28_enhanced<br>                        Title: ANSSI-BP-028 (high)<br>                                Id: xccdf_org.ssgproject.content_profile_anssi_bp28_high<br>                        Title: ANSSI-BP-028 (intermediary)<br>                                Id: xccdf_org.ssgproject.content_profile_anssi_bp28_intermediary<br>                        Title: ANSSI-BP-028 (minimal)<br>                                Id: xccdf_org.ssgproject.content_profile_anssi_bp28_minimal<br>                        Title: [DRAFT] CIS Red Hat Enterprise Linux 9 Benchmark for Level 2 - Server<br>                                Id: xccdf_org.ssgproject.content_profile_cis<br>                        Title: [DRAFT] CIS Red Hat Enterprise Linux 9 Benchmark for Level 1 - Server<br>                                Id: xccdf_org.ssgproject.content_profile_cis_server_l1<br>                        Title: [DRAFT] CIS Red Hat Enterprise Linux 9 Benchmark for Level 1 - Workstation<br>                                Id: xccdf_org.ssgproject.content_profile_cis_workstation_l1<br>                        Title: [DRAFT] CIS Red Hat Enterprise Linux 9 Benchmark for Level 2 - Workstation<br>                                Id: xccdf_org.ssgproject.content_profile_cis_workstation_l2<br>                        Title: [DRAFT] Unclassified Information in Non-federal Information Systems and Organizations (NIST 800-171)<br>                                Id: xccdf_org.ssgproject.content_profile_cui<br>                        Title: Australian Cyber Security Centre (ACSC) Essential Eight<br>                                Id: xccdf_org.ssgproject.content_profile_e8<br>                        Title: Health Insurance Portability and Accountability Act (HIPAA)<br>                                Id: xccdf_org.ssgproject.content_profile_hipaa<br>                        Title: Australian Cyber Security Centre (ACSC) ISM Official<br>                                Id: xccdf_org.ssgproject.content_profile_ism_o<br>                        Title: [DRAFT] Protection Profile for General Purpose Operating Systems<br>                                Id: xccdf_org.ssgproject.content_profile_ospp<br>                        Title: PCI-DSS v3.2.1 Control Baseline for Red Hat Enterprise Linux 9<br>                                Id: xccdf_org.ssgproject.content_profile_pci-dss<br>                        Title: [DRAFT] DISA STIG for Red Hat Enterprise Linux 9<br>                                Id: xccdf_org.ssgproject.content_profile_stig<br>                        Title: [DRAFT] DISA STIG with GUI for Red Hat Enterprise Linux 9<br>                                Id: xccdf_org.ssgproject.content_profile_stig_gui<br>                Referenced check files:<br>                        ssg-rhel9-oval.xml<br>                                system: http://oval.mitre.org/XMLSchema/oval-definitions-5<br>                        ssg-rhel9-ocil.xml<br>                                system: http://scap.nist.gov/schema/ocil/2<br>                        security-data-oval-com.redhat.rhsa-RHEL9.xml.bz2<br>                                system: http://oval.mitre.org/XMLSchema/oval-definitions-5<br>Checks:<br>        Ref-Id: scap_org.open-scap_cref_ssg-rhel9-oval.xml<br>        Ref-Id: scap_org.open-scap_cref_ssg-rhel9-ocil.xml<br>        Ref-Id: scap_org.open-scap_cref_ssg-rhel9-cpe-oval.xml<br>        Ref-Id: scap_org.open-scap_cref_security-data-oval-com.redhat.rhsa-RHEL9.xml.bz2<br>Dictionaries:<br>        Ref-Id: scap_org.open-scap_cref_ssg-rhel9-cpe-dictionary.xml |

|   |   |
|---|---|
|[3]|Scan CentOS System with [oscap] command.  <br>Scan result is renerated as HTML report, you should verify it and try to apply recommended settings as much as possible.|

|   |
|---|
|# xccdf : specify [xccdf] module  <br># ⇒ available modules : info, xccdf, oval, ds, cpe, cvss, cve, cvrf  <br># [--profile] : specify profile  <br># ⇒ available profiles are on the result you run [oscap info] command above  <br># [--results] : output file  <br># [--report] : output HTML report<br><br>[root@dlp ~]# <br><br>oscap xccdf eval \  <br>--profile xccdf_org.ssgproject.content_profile_ospp \  <br>--results ssg-cs9-ds.xml \  <br>--report ssg-cs9-ds.html \  <br>/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml<br><br>  <br><br>Downloading: https://access.redhat.com/security/data/oval/com.redhat.rhsa-RHEL9.xml.bz2 ... ok<br>--- Starting Evaluation ---<br><br>Title   Install AIDE<br>Rule    xccdf_org.ssgproject.content_rule_package_aide_installed<br>Result  fail<br><br>Title   Enable Dracut FIPS Module<br>Rule    xccdf_org.ssgproject.content_rule_enable_dracut_fips_module<br>Result  fail<br><br>Title   Enable FIPS Mode<br>Rule    xccdf_org.ssgproject.content_rule_enable_fips_mode<br>Result  fail<br><br>Title   Install crypto-policies package<br>Rule    xccdf_org.ssgproject.content_rule_package_crypto-policies_installed<br>Result  pass<br><br>Title   Configure BIND to use System Crypto Policy<br>Rule    xccdf_org.ssgproject.content_rule_configure_bind_crypto_policy<br>Result  pass<br><br>Title   Configure System Cryptography Policy<br>Rule    xccdf_org.ssgproject.content_rule_configure_crypto_policy<br>Result  fail<br><br>Title   Configure Kerberos to use System Crypto Policy<br>Rule    xccdf_org.ssgproject.content_rule_configure_kerberos_crypto_policy<br>Result  pass<br><br>.....<br>.....|

|   |
|---|
|![](https://www.server-world.info/en/CentOS_Stream_9/openscap/img/1.png)|
|![](https://www.server-world.info/en/CentOS_Stream_9/openscap/img/2.png)|
|![](https://www.server-world.info/en/CentOS_Stream_9/openscap/img/3.png)|
|![](https://www.server-world.info/en/CentOS_Stream_9/openscap/img/5.png)|

|   |   |
|---|---|
|[4]|It's possible to generate remediation script from scaned result.<br><br>Remediation script will change various system settings, so you must take care if you run it, especially for production systems.|

|   |
|---|
|# make sure the [Result ID] in the result output on [3]<br><br>  <br>[root@dlp ~]# <br><br>oscap info ssg-cs9-ds.xml \| grep "Result ID"<br><br>  <br><br>        Result ID: xccdf_org.open-scap_testresult_xccdf_org.ssgproject.content_profile_ospp<br><br># generate remediation script  <br># [--fix-type] : specify fix type : default is Bash  <br># ⇒ available type ⇒ bash, ansible, puppet, anaconda, ignition, kubernetes, blueprint  <br># [--output] : specify output script file  <br># [--result-id] : specify [Result ID]<br><br>[root@dlp ~]# <br><br>oscap xccdf generate fix \  <br>--fix-type bash \  <br>--output ssg-cs9-ds-remediation.sh \  <br>--result-id xccdf_org.open-scap_testresult_xccdf_org.ssgproject.content_profile_ospp \  <br>ssg-cs9-ds.xml<br><br>[root@dlp ~]# <br><br>[ll](https://www.server-world.info/en/command/html/ls.html)<br><br>  <br><br>total 16172<br>-rw-------. 1 root root     1100 Nov 26  2021 anaconda-ks.cfg<br>-rw-r--r--. 1 root root  2286030 Jul 29 09:37 ssg-cs9-ds.html<br>-rwx------. 1 root root   183754 Jul 29 09:55 ssg-cs9-ds-remediation.sh<br>-rw-r--r--. 1 root root 14081044 Jul 29 09:37 ssg-cs9-ds.xml<br><br># run remediation script<br><br>  <br>[root@dlp ~]# <br><br>./ssg-cs9-ds-remediation.sh<br><br>  <br><br>.....<br>.....<br>Remediating rule 111/112: 'xccdf_org.ssgproject.content_rule_service_usbguard_enabled'<br>Created symlink /etc/systemd/system/basic.target.wants/usbguard.service �� /usr/lib/systemd/system/usbguard.service.<br>Remediating rule 112/112: 'xccdf_org.ssgproject.content_rule_usbguard_allow_hid_and_hub'<br><br># check again<br><br>  <br>[root@dlp ~]# <br><br>oscap xccdf eval \  <br>--profile xccdf_org.ssgproject.content_profile_ospp \  <br>--results ssg-cs9-ds_after-remediation.xml \  <br>--report ssg-cs9-ds_after-remediation.html \  <br>/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml|

|   |   |
|---|---|
||After running remediation script, many [fail] items has been improved.|

|   |
|---|
|![](https://www.server-world.info/en/CentOS_Stream_9/openscap/img/6.png)|