%include	/usr/lib/rpm/macros.perl
Summary:	SMS perl module
Summary(pl):	Modu³ perla SMS
Name:		perl-SMS
Version:	0.3.9
Release:	1
License:	distributable
Group:		Development/Languages/Perl
Source0:	http://rmb.miech.pl/sms/SMS.pm
BuildRequires:	rpm-perlprov >= 3.0.3-16
BuildRequires:	perl >= 5.6
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description
This perl module provides interface for sending SMS via various gateways.

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT

install -d $RPM_BUILD_ROOT%{perl_sitelib}
install %{SOURCE0} $RPM_BUILD_ROOT%{perl_sitelib}


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%{perl_sitelib}/*
