package SMS;

use strict;
use CGI::Cookie;
use LWP::UserAgent;
use HTTP::Request::Common qw(GET POST);
use HTTP::Response;


=head1

 SMS.pm 0.3.9

 From version 0.3.4 by Roman "RmB" Barczynski <rmb@miech.pl>

 SMS.pm 0.3.9, obs³uga nowej bramki ERY [du¿o to oni nie zmienili ;)] by Daniel Lukasiak <estrai@estrai.com>
 SMS.pm 0.3.8, obs³uga proxy w send_plus by Adam Filipiak <adam.filipiak@atosorigin.com>
 SMS.pm 0.3.7, obs³uga nowych numerów sieci by Bartosz Wucke <sharp@solutions.net.pl>
 SMS.pm 0.3.6, "->send"  zwraca status operacji (1/0)...
 SMS.pm 0.3.5, 07/09/2001
               nowe numery sieci by Andrzej Wojkowski <admin@cordef.net.pl>
               send_plus_email by RmB
 SMS.pm 0.3.4, 04/09/2001
		nowy kod bramki idei by RmB
		oraz plusa by Slawomir Chroszcz
		obsluga odpowiedzi bramek "->response()" by RmB
 SMS.pm 0.3.3, by Krzysztof Juszkiewicz <juszkiew@saturn.kt.agh.edu.pl>, 15/02/2001
 SMS.pm 0.3.2, by mariusz.jedrzejewski@polcard.com.pl, 15/01/2001
 SMS.pm 0.3.1, by damian.szalewicz@pro-creation.pl, 27/10/2000
 SMS.pm 0.3, by L.Felsztukier@digitalone.pl
 SMS.pm 0.1, by alder@amg.net.pl

=begin html
 <a href="SMS.pm">Sciagnij modul</a>

=end html

=cut



sub new {
    my ($c, %args) = @_;
    my $class = ref($c) || $c;

    die "Podaj poprawny numer telefonu" unless $args{numer} =~ /^\d+$/;
    $args{tekst} = "";

    # dlugosc sms-a (ja wole krotkie, ale jak ktos chce ...)
    $args{maxSMS} = 160;
    $args{sendmail} = "/usr/lib/sendmail";
    
    bless \%args, $class;
}


sub message {
    my ($cl, $mess) = @_;
    $cl->{tekst} = substr($mess,0,$cl->{maxSMS});
    return $cl->{tekst};
}

sub from {
    my ($cl, $mess) = @_;
    $cl->{from} = $mess;
    return $cl->{from};
}

sub email {
    my ($cl, $email) = @_;
    $cl->{email} = $email;
    return $cl->{email};
}

sub response {
    my ($cl) = @_;
    return $cl->{response};
}


sub send { 
    my $cl = shift;
    my $no = $cl->{numer} || die "Nie podano numeru telefonu\n";

    if ($no =~ /^(60[02468]|69[2468])/) {
	return $cl->send_era;
    } elsif ($no =~ /^(6[09][13579])/) {
	return $cl->send_plus;
    } elsif ($no =~ /^(50[0-9])/) {
	return $cl->send_idea;
    } else {
	# miejsce na dorobienie implementacji dla innych sieci
	die "Wysy³anie do tej sieci nie zaimplementowane\n"; 
    }
}

sub send_plus {
    my $cl = shift;
    my $mess = $cl->{tekst};
    my $from = $cl->{from};
    my ($prefix,$numer)=($cl->{numer} =~ /^(...)(.+)/);

    # w tresc sms-a wchodzi tez adres email oraz kilka znakow typu SMS OD: 
    $mess = substr($mess,0,$cl->{maxSMS}-length($cl->{email})-10 );


    my $ua = new LWP::UserAgent;
    $ua->agent("Mozilla/3.0 (X11; I; Linux 2.2.9 i686)");
    $ua->timeout(900);
    
    # Sprawdzamy, czy ustawione proxy
    if ($cl->{proxy_type} && $cl->{proxy_url}) {
  $ua->proxy($cl->{proxy_type}, $cl->{proxy_url});
    }
    
    # Zapodajemy finalne zapytanie
    my $post =
        POST "http://www.text.plusgsm.pl/sms/sendsms.php",
        [sms => "", tprefix => "$prefix",  numer => "$numer", odkogo => 
	"$from", mail => "$from", tekst => "$mess"],
        Referer => "http://www.text.plusgsm.pl/sms/";
							
    my $res = $ua->request($post);

    if ($res->is_success) {
      my $ODP = $res->content;
      if ($ODP =~ qr/wiadomo.. zosta..? wys.an/im ) {
        $cl->{response} = "Wyslany : " . $res->code ;
	return 1;
      } elsif ($ODP =~ qr/jest niepoprawny/im ) {
        $cl->{response} = "Zly numer... : "  . $res->code ;
      } else {
        $cl->{response} = "Nieznana odpowiedz:\n----$ODP\n---- : "  . $res->code ;
      }
    } else {
      $cl->{response} = "Bramka nie odpowiada... : "  . $res->code ;
    }      
    
    return 0;
}							    

sub send_plus_email {
    my $cl = shift;
    my $mess = $cl->{tekst};
    my $from = $cl->{from};
    my $numer = $cl->{numer};
    my $prefix = '+48';
    my $sendmail = $cl->{sendmail};

    # w tresc sms-a wchodzi tez adres email oraz kilka znakow typu SMS OD: 
    $mess = substr($mess,0,$cl->{maxSMS}-length($cl->{email})-10 );

    open(MAIL,"|$sendmail -t ".$prefix.$numer."\@text.plusgsm.pl");
    print MAIL "To: ",      $prefix.$numer."\@text.plusgsm.pl\n";
    print MAIL "From: ",    $from,"\n";
    print MAIL "Subject: ", $mess,"\n\n";
    close (MAIL);

    $cl->{response} = "Wyslany";
    return 1;
}


sub send_idea {
    my $cl = shift;
    my $mess = $cl->{tekst};
    my $TO = $cl->{numer};

    # w tresc sms-a wchodzi tez adres email oraz kilka znakow typu SMS OD:
    $mess = substr($mess,0,$cl->{maxSMS}-length($cl->{from})-10 );
    
    my $ua = new LWP::UserAgent;
    $ua->agent("Mozilla/3.0 (X11; I; Linux 2.2.9 i686)");
    $ua->timeout(900);

    # Sprawdzamy, czy ustawione proxy
    if ($cl->{proxy_type} && $cl->{proxy_url}) {
	$ua->proxy($cl->{proxy_type}, $cl->{proxy_url});
    }

    # no niestety IDEA wymaga teraz podania dokladnych parametrow czasowych :)
    
    my $time = time - 10; #bo przecie napisanie sms-a troche trwa ...
    my ($s,$m,$g,$dz,$mi,$rok) = localtime($time);
    if ($m < 10) { $m = "0$m"; }
    if ($g < 10) { $g = "0$g"; }
    $mi++; $rok+=1900;
    if ($dz < 10) { $dz = "0$dz"; }
    if ($mi < 10) { $mi = "0$mi"; }
    
    # zmienil sie tez adres bramki
    my $post = 
	POST "http://sms.idea.pl/sendsms.asp",
	[LANGUAGE => "pl", NETWORK => "smsc1", DELIVERY_TIME => "$time", NOTIFICATION_ADDRESS => "",
	 SENDER => $cl->{from}, RECIPIENT => "$TO", VALIDITY_PERIOD => "24",
	 DELIVERY_DATE => "$dz", DELIVERY_MONTH => "$mi", DELIVERY_YEAR => "$rok", DELIVERY_HOUR => "$g", DELIVERY_MIN => "$m",
	 SHORT_MESSAGE => "$mess"],
	Referer => "http://sms.idea.pl/default.asp";

    my $res = $ua->request($post);
    if ($res->is_success) {
      my $ODP = $res->content;
      if ($ODP =~ qr/zosta³a wys³ana/im ) {
        $cl->{response} = "Wyslany";
	return 1;
      } elsif ($ODP =~ qr/(Odbiorca nieznany)|(Blednie wpisany)/im ) {
        $cl->{response} = "Zly numer...";
      } elsif ($ODP =~ qr/wyczerpany/im ) {
        $cl->{response} = "Limit wiadomosci na 24h przekroczony";
      } elsif ($ODP =~ qr/nie ma aktywnej/im ) {
        $cl->{response} = "Odbiorca nie ma aktywnej uslugi IDEA-mail";
      } else {
        $cl->{response} = "Nieznana odpowiedz:\n----$ODP\n----";
      }
    } else {
      $cl->{response} = "Bramka nie odpowiada...";
    }      
    return 0;
}


sub send_era {
    my $cl = shift;
    my $mess = $cl->{tekst};
    my $TO = $cl->{numer};
    my $CODE;
    my $KOD;

    # w tresc sms-a wchodzi tez adres email oraz kilka znakow typu SMS OD:
    # era dobija glupkowate reklamy ...
    $mess = substr($mess,0,$cl->{maxSMS} - length($cl->{from})-40 );
    
    my $ua = new LWP::UserAgent;
    $ua->agent("Mozilla/3.0 (X11; I; Linux 2.2.9 i686)");
    $ua->timeout(900);

    # Sprawdzamy, czy ustawione proxy
    if ($cl->{proxy_type} && $cl->{proxy_url}) {
	$ua->proxy($cl->{proxy_type}, $cl->{proxy_url});
    }

    # Pobieramy ciacho
    my $get = POST "http://boa.era.pl/sms/sendsms.asp", [sms=>1];
    my $heh = $ua->request($get);
    my %COOK = CGI::Cookie->parse($heh->headers->header('Set-Cookie'));
    my $cookie;
    for (keys %COOK) { 
	if (/ASPSESSIONID/i){ $cookie = $COOK{$_}; } 
    }

    # Pobieramy tajny kod dostêpu
    my $src = 
	POST "http://boa.era.pl/sms/sendsms.asp", [sms=>1],
	Referer => "http://boa.era.pl/sms/sendsms.asp",
	Cookie => "$cookie";

    my $fuck = $ua->request($src);
    my $source = $fuck->content;
    if ($source =~ /name="kod"\s+value="(\d+)"/i) { 
	$CODE = $1;
    }
	if ($source =~ /name="Kod(\d+)"/i) { 
		$KOD = $1;
	}

    # Zapodajemy finalne zapytanie
    my $post = 
	POST "http://boa.era.pl/sms/sendsms.asp",
	[bookopen => "  ", numer => "$TO", message => "$mess", podpis => $cl->{from}, kod => "$CODE", kontakt => "", Nadaj => "Nadaj", "Kod$KOD" => "$CODE", Send => "1", sms => "1"], 
	Cookie => "$cookie",
	Referer => "http://boa.era.pl/sms/sendsms.asp";

    my $res = $ua->request($post);
    if ($res->is_success) {
      my $ODP = $res->content;
      if ($ODP =~ qr/zosta³a wys³ana/im ) {
        $cl->{response} = "Wyslany";
	return 1;
      } elsif ($ODP =~ qr/spoza sieci/im ) {
        $cl->{response} = "Zly numer...";
      } else {
        $cl->{response} = "Nieznana odpowiedz:\n----$ODP\n----"
      }
    } else {
      $cl->{response} = "Bramka nie odpowiada...";
    }      
    return 0;
}


sub proxy_type {
    my ($cl, $type) = @_;
    $cl->{proxy_type} = $type;
    return $cl->{proxy_type};
}


sub proxy_url {
    my ($cl, $url) = @_;
    $cl->{proxy_url} = $url;
    return $cl->{proxy_url};
}


1;
