using System;

namespace SmallObjects.Bond
{

	public static class BondTypeAliasConverter
	{
		public static decimal Convert(ArraySegment<byte> value, decimal unused)
		{
			var bits = new int[value.Count / sizeof(int)];
			Buffer.BlockCopy(value.Array, value.Offset, bits, 0, bits.Length * sizeof(int));
			return new decimal(bits);
		}

		public static ArraySegment<byte> Convert(decimal value, ArraySegment<byte> unused)
		{
			var bits = decimal.GetBits(value);
			var data = new byte[bits.Length * sizeof(int)];
			Buffer.BlockCopy(bits, 0, data, 0, data.Length);
			return new ArraySegment<byte>(data);
		}
		public static long Convert(DateTime value, long unused)
		{
			return value.Ticks;
		}

		public static DateTime Convert(long value, DateTime unused)
		{
			return new DateTime(value);
		}

		public static GUID Convert(Guid value, GUID unused)
		{
			var bytes = value.ToByteArray();
			return new GUID
			{
				Data1 = (uint)((bytes[0] << 24) + (bytes[1] << 16) + (bytes[2] << 8) + bytes[3]),
				Data2 = (ushort)((bytes[4] << 8) + bytes[5]),
				Data3 = (ushort)((bytes[6] << 8) + bytes[7]),
				Data4 = (ulong)((bytes[8] << 56) + (bytes[9] << 48) + (bytes[10] << 40) + (bytes[11] << 32) + (bytes[12] << 24) + (bytes[13] << 16) + (bytes[14] << 8) + bytes[3])
			};
		}

		public static Guid Convert(GUID value, Guid unused)
		{
			var d4 = value.Data4;
			return new Guid(value.Data1, value.Data2, value.Data3, (byte)(d4 >> 56), (byte)(d4 >> 48), (byte)(d4 >> 40), (byte)(d4 >> 32), (byte)(d4 >> 24), (byte)(d4 >> 16), (byte)(d4 >> 8), (byte)d4);
		}
	}

}