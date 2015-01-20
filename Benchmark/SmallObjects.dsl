module SmallObjects {
	value Message {
		string message;
		int version;
	}
	guid root Post {
		string title;
		bool active;
		date created;
	}
	value Complex {
		decimal x;
		float y;
		long z;
	}
}