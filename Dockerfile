FROM perl

MAINTAINER Denis T. <dev@denis-it.com>

WORKDIR /usr/src/bookingbot

COPY cpanfile ./

RUN cpanm --installdeps . \
	&& git clone https://denis-it@bitbucket.org/serikov/serikoff.lib.git

COPY . .

ENTRYPOINT ["morbo", "-w", "fabbook_polling.conf", "fabbook_polling.pl"]
