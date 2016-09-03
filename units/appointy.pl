#!/usr/bin/env perl
use common::sense;
use Mojo::UserAgent;
use Data::Dumper;

my $ua = Mojo::UserAgent->new;


my %hash = (
	serviceNameOnBook =>  'RepRap Mendel Tricolour',
	serviceCostOnBook =>  '75',
	serviceQuantityOnBook =>  '1',
	serviceId => '296171',
	staffId => '136563',
	startTime => '9/3/2016 18:30:0',
	appointmentDate => '9/3/2016',
	chkUserPayLaterInput => 0,
	payLaterOrNowCon => 'undefined',
	totalServiceCost => 75,
	serQuantity => 1,
	SeviceAdonsPrice => 0,
	OrderAdonsPrice => 0,
	TotalAdonsPrice => 0,
	AmountOfDiscount => 0,
	totalServiceCostBeforTax => 75,
	ResourceIds => 0
);

warn Dumper $ua->post('http://fablab61.appointy.com/Mobile/insertAvailableAppointmentFromCheckout.aspx' => form => \%hash)->res;