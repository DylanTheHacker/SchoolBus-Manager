using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.WebSockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.WebSockets;
using System.IO;
using Common;

namespace WebBus
{

    /// <summary>
    /// WebSocketHandler 的摘要说明
    /// </summary>
    public class WebSocketHandler : IHttpHandler
    {
        private static Dictionary<string, WebSocket> CONNECT_POOL = new Dictionary<string, WebSocket>();//用户连接池
        private static Dictionary<string, List<string>> MESSAGE_POOL = new Dictionary<string, List<string>>();//离线消息池
        public void ProcessRequest(HttpContext context)
        {
            //LogDirectory = HttpContext.Current.Request.MapPath("/LOG/");
            Utils.WriteTraceLog("websocket request start");
            if (context.IsWebSocketRequest)
            {
                //Utils.WriteLog("websocket", "websocket connect");
                Utils.WriteTraceLog("websocket connect");
                context.AcceptWebSocketRequest(ProcessChat);
            }
            else
            {
                Utils.WriteTraceLog("not websocket request");                
            }
        }

        private async Task ProcessChat(AspNetWebSocketContext context)
        {
            WebSocket socket = context.WebSocket;
            string user = context.QueryString["user"].ToString();

            try
            {
                #region 用户添加连接池
                //第一次open时，添加到连接池中
                if (!CONNECT_POOL.ContainsKey(user))
                    CONNECT_POOL.Add(user, socket);//不存在，添加
                else
                {
                    if (socket != CONNECT_POOL[user])//当前对象不一致，更新
                    {
                        CONNECT_POOL[user] = socket;
                    }
                     
                }
                Utils.WriteTraceLog("websocket length:" + CONNECT_POOL.Count); 
                
                #endregion

                //链接上后先查看有没有离线消息，如果有则先发送离线消息
                #region 离线消息处理
                if (MESSAGE_POOL.ContainsKey(user))
                {
                    //string userid = MESSAGE_POOL[user];
                    List<string> msgList = MESSAGE_POOL[user];
                    //发送离线消息
                    foreach (string item in msgList)
                    {
                        //string userMsg = Encoding.UTF8.GetString(buffer.Array, 0, result.Count);//发送过来的消息
                        BLL.BLLChat bllChat = new BLL.BLLChat(item);
                        //byte[] msgByte = System.Text.Encoding.UTF8.GetBytes(bllChat.msgContent);
                        byte[] msgByte = System.Text.Encoding.UTF8.GetBytes(bllChat.msgText);
                        await socket.SendAsync(new ArraySegment<byte>(msgByte), WebSocketMessageType.Text, true, CancellationToken.None);
                    }
                    MESSAGE_POOL.Remove(user);//移除离线消息
                }
                #endregion

                //string descUser = string.Empty;//目的用户
                while (true)
                {
                    if (socket.State == WebSocketState.Open)
                    {
                        ArraySegment<byte> buffer = new ArraySegment<byte>(new byte[2048]);
                        WebSocketReceiveResult result = await socket.ReceiveAsync(buffer, CancellationToken.None);

                        #region 消息处理（字符截取、消息转发）
                        try
                        {
                            #region 关闭Socket处理，删除连接池
                            if (socket.State != WebSocketState.Open)//连接关闭
                            {
                                if (CONNECT_POOL.ContainsKey(user))
                                    CONNECT_POOL.Remove(user);//删除连接池
                                break;
                            }
                            #endregion
                            string userMsg = Encoding.UTF8.GetString(buffer.Array, 0, result.Count);//发送过来的消息
                            Utils.WriteTraceLog("websocket receive:" + userMsg);                            
                            BLL.BLLChat bllChat = new BLL.BLLChat(userMsg);
                            //byte[] msgByte = System.Text.Encoding.UTF8.GetBytes(bllChat.msgContent);
                            byte[] msgByte = System.Text.Encoding.UTF8.GetBytes(bllChat.msgText);
                            //如果在线
                            for (int i = 0; i < bllChat.toIdList.Length; i++)
                            {
                                string descUser = bllChat.toIdList[i];                                
                                if (CONNECT_POOL.ContainsKey(descUser))//判断客户端是否在线
                                {
                                    WebSocket destSocket = CONNECT_POOL[descUser];//目的客户端
                                    if (destSocket != null && destSocket.State == WebSocketState.Open)
                                    {
                                        await destSocket.SendAsync(new ArraySegment<byte>(msgByte), WebSocketMessageType.Text, true, CancellationToken.None);                                        
                                    }
                                }
                                else
                                {
                                    await Task.Run(() =>
                                    {
                                        if (!MESSAGE_POOL.ContainsKey(descUser))//将用户添加至离线消息池中
                                        {
                                            List<string> msgList = new List<string>();
                                            MESSAGE_POOL.Add(descUser, msgList);
                                        }
                                        MESSAGE_POOL[descUser].Add(userMsg);//添加离线消息
                                        Utils.WriteTraceLog("websocket off-line:" + user);
                                    });
                                }
                            }
                        }
                        catch (Exception exs)
                        {
                            //消息转发异常处理，本次消息忽略 继续监听接下来的消息
                            Utils.WriteTraceLog("websocket Exception");
                        }
                        #endregion
                    }
                    else
                    {
                        break;
                    }
                }//while end
            }
            catch (Exception ex)
            {
                Utils.WriteTraceLog("websocket  ProcessChat Exception");               
                //整体异常处理
                if (CONNECT_POOL.ContainsKey(user))
                {
                    CONNECT_POOL.Remove(user);
                }                    
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}