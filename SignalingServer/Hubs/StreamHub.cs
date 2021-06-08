using Microsoft.AspNetCore.SignalR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Channels;
using System.Threading.Tasks;

namespace SignalingServer.Hubs
{
    public class StreamHub: Hub
    {
        public ChannelReader<int> DelayCounter(int delay)
        {
            var channel = Channel.CreateUnbounded<int>();

            _ = WriteItems(channel.Writer, 10, delay);

            return channel.Reader;
        }

        private async Task WriteItems(ChannelWriter<int> writer, int count, int delay)
        {
            for (var i = 0; i < count; i++)
            {
                await writer.WriteAsync(i);
                
                await Task.Delay(delay);
            }

            writer.TryComplete();
        }

        public async Task MoveViewFromServer(float newX, float newY)
        {
            await Clients.Others.SendAsync("ReceiveNewPosition", newX, newY);
            Console.WriteLine($"Receive position from server app: {newX}/{newY}");
        }
    }
}
