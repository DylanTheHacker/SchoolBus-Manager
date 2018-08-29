using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;

namespace BLL
{
    public class BLLChat
    {
        public string fromId { get; set; }
        public string type { get; set; }//定义1为群聊，2为私聊
        public string toId { get; set; }
        public string[] toIdList { get; set; }
        public string msgContent { get; set; }
        public string msgText { get; set; }
        public BLLChat(string msg)
        {
            JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
            var chatDict = jsSerializer.Deserialize<Dictionary<String, object>>(msg);           
            fromId = chatDict["fromId"] == null ? string.Empty : chatDict["fromId"].ToString();
            type = chatDict["type"] == null ? string.Empty : chatDict["type"].ToString();
            toId = chatDict["toId"] == null ? string.Empty : chatDict["toId"].ToString();
            msgContent = chatDict["msgContent"] == null ? string.Empty : chatDict["msgContent"].ToString();
            //msgText = chatDict["msgContent"] == null ? string.Empty : string.Format("{0} {1}:",DateTime.Now.ToLocalTime().ToString(),fromId) + msgContent;
            msgText = chatDict["msgContent"] == null ? string.Empty : msgContent;
            toIdList = null;
            //如果是群聊则获取车上所有乘车人员的id
            if (type.Equals("1"))
            {
                string busid = toId;
                //BLLB
                BLLBus bllBus = new BLLBus();
                toIdList = bllBus.getUserIDListByBusID(busid);
            }
            //私聊
            else
            {
                toIdList = new string[1];
                toIdList[0] = toId;
            }
        }
    }
}
