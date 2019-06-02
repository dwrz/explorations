#include <unistd.h>
#include <string.h>

const int MAX_INPUT_LENGTH = 100;

int main(void) {
	char str[MAX_INPUT_LENGTH];

	write(1, "Type something:\n", 18);
	read(0, str, MAX_INPUT_LENGTH);

	int inputLength = strlen(str);
	if (inputLength > MAX_INPUT_LENGTH) inputLength = MAX_INPUT_LENGTH;

	write(1,"\nYou entered:\n", 16);
	write(1, str, inputLength);
}
