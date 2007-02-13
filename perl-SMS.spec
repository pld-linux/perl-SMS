%include	/usr/lib/rpm/macros.perl
Summary:	SMS Perl module - sending SMS via various Polish gateways
Summary(pl.UTF-8):	Moduł Perla SMS - wysyłanie SMS-ów za pośrednictwem bramek różnych polskich operatorów GSM
Name:		perl-SMS
Version:	0.3.9
Release:	5
License:	unknown
Group:		Development/Languages/Perl
Source0:	http://romke.biz/inne/sms/SMS.pm
# Source0-md5:	371a2a08d99100931c3529fb4e2d05da
BuildRequires:	rpm-perlprov >= 4.1-13
BuildRequires:	perl-devel >= 1:5.8.0
# for dependency resolving
BuildRequires:	perl-CGI
BuildRequires:	perl-libwww
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description
This Perl module provides interface for sending SMS via various
Polish gateways.

%description -l pl.UTF-8
Ten moduł Perla udostępnia interfejs dla wysyłania SMS-ów za
pośrednictwem bramek różnych polskich operatorów GSM.

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT

install -d $RPM_BUILD_ROOT%{perl_vendorlib}
install %{SOURCE0} $RPM_BUILD_ROOT%{perl_vendorlib}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%{perl_vendorlib}/*
