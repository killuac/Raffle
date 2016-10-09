{\rtf1\ansi\ansicpg1252\cocoartf1343\cocoasubrtf140
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural

\f0\fs24 \cf0 =====================================================================\
Ad Network Adapter for Google AdMob Ads Mediation SDK for Android\
=====================================================================\
\
Requirements:\
- A Mediation ID\
- Google Ads SDK\
- Mopub SDK \
\
Instructions:\
- Add the libAdapterSDKMoPub.a included here\
- Follow this start guide to integrate mopub sdk https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started\
- Enable the Ad network in the Ad Network Mediation UI.\
- Make ad requests normally using the AdMob SDK using the mediation \
	ID for the placement rather than the publisher ID.\
\
Notes:\
Adapters do not pass any information about adsizes from DFP to mopub. So please make sure you use the same adsize in DFP as the one created in mopub UI dashboard  }