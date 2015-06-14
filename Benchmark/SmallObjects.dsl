module SmallObjects {
	value Message {
		string message;
		int version;
	}
	value Post {
		guid ID { 
			//otherwise we will get a new guid as default
			default c# 'System.Guid.Empty';
			default Java 'com.dslplatform.client.Utils.MIN_UUID'; 
		}
		string title;
		bool active;
		date created {
			//otherwise we will get current date
			default c# 'System.DateTime.MinValue';
			default Java 'com.dslplatform.client.Utils.MIN_LOCAL_DATE'; 
		}
	}
	value Complex {
		decimal x;
		float y;
		long z;
	}
}