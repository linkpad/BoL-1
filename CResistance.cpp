void CResistance::calculercouleur(void)
{
	char buffer [50];
	double temp = getValeur();
	sprintf (buffer, "%f" , temp);
	if (buffer[0]=='0' && buffer[1]=='.')
	{	
		mAnneau1=couleur(buffer[2]-'0');
		mAnneau2=couleur(buffer[3]-'0');
		if(buffer[3]=='0')
		{
			mAnneau3=couleur(int(log10(mValeur)-1));
		}
		if(buffer[3]!='0' && buffer[2]!='0')
		{
			mAnneau3=couleur(int(log10(mValeur)-2));
		}

	}
	if (buffer[1]!='.')
	{
		mAnneau1=couleur(buffer[0]-'0');
		mAnneau2=couleur(buffer[1]-'0');
		mAnneau3=couleur(int(log10(mValeur)-1));
	}
	if (buffer[0]!='0' && buffer[1]=='.')
	{
		mAnneau1=couleur(buffer[0]-'0');
		mAnneau2=couleur(buffer[2]-'0');
		mAnneau3=couleur(int(log10(mValeur)-2));
	}


	if(mAnneau4==marron || mAnneau4==orange ||mAnneau4==jaune ||mAnneau4==vert ||mAnneau4==bleu ||mAnneau4==violet ||mAnneau4==gris ||mAnneau4==blanc)
	{
		setTolerance(20);
	}
	if(mAnneau4==0)
	{
		setTolerance(20);
	}
	if(mAnneau4==2)
	{
		setTolerance(2);
	}
	if(mAnneau4==10)
	{
		setTolerance(5);
	}
	if(mAnneau4==11)
	{
		setTolerance(10);
	}
	if(mAnneau4==12)
	{
		setTolerance(20);
	}

}
