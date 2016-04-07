// *****************
// Input argument
// r4: number to be converted to string
// r5: pointer to the string
// *****************

void int_to_string(unsigned int value, char* result) {

	char* ptr=result;
    unsigned int tmp_value;
    int counter=0;
    int i;
    char c;

	while(value&&counter<10){
		tmp_value=value;
		value/=10;
		tmp_value=tmp_value-value*10; // the last digit from the value
		*ptr=tmp_value+'0';
		ptr++;
		counter++;
	}

	for(i=0;i<counter/2;i++){
		c=result[i];
		result[i]=result[counter-1-i];
		result[counter-1-i]=c;
	}
}
