module SmallObjects {
	value Message {
		string message;
		int version;
	}
	root Post {
		string title;
		string text;
		date created;
	}
	value Complex {
		decimal x;
		float y;
		long z;
	}
}