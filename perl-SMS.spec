%include	/usr/lib/rpm/macros.perl
Summary:	SMS Perl module
Summary(pl):	Modu³ Perla SMS
Name:		perl-SMS
Version:	0.3.9
Release:	2
License:	distributable
Group:		Development/Languages/Perl
Source0:	http://rmb.miech.pl/sms/SMS.pm
BuildRequires:	rpm-perlprov >= 4.1-13
BuildRequires:	perl >= 5.6
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description
This Perl module provides interface for sending SMS via various
gateways.

%description -l pl
Ten modu³ Perla udostêpnia interfejs dla wysy³ania SMS-ów za
po¶rednictwem ró¿nych bramek.

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
%{perl_sitelib}/*
