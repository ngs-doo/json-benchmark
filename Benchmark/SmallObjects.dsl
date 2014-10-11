module SmallObjects {
	event Message {
		string message;
	}
	root Post {
		string title;
		string text;
		date created;
	}
	value Complex {
		decimal x;
		decimal y;
	}
}