using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Web.Script.Serialization;
using BLL;
using Model;
using Common;

namespace WebBus
{
    /// <summary>
    /// requestParentSelectedVehicle 的摘要说明
    /// </summary>
    public class UploadParentSelectedVehicle : IHttpHandler
    {
        private class RequestData
        {
            public string AccessToken { get; set; }
            public string ParentID { get; set; }
            public string BusID { get; set; }
        }
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                Utils.WriteTraceLog("UploadParentSelectedVehicle start"); 
                StreamReader reader = new StreamReader(context.Request.InputStream);
                string str = reader.ReadToEnd();
                reader.Close();
                string ResultCode = string.Empty;
                BLLBus bLLBus = new BLLBus();
                BLLUsers bLLUsers = new BLLUsers();
                Dictionary<string, object> dict = new Dictionary<string, object>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                RequestData requestData = jsSerializer.Deserialize<RequestData>(str);
                if (requestData == null)
                {
                    ResultCode = "2901";
                }
                else if (requestData.AccessToken == string.Empty || requestData.AccessToken == null)
                {
                    ResultCode = "2902";
                }
                else if (requestData.ParentID == string.Empty || requestData.ParentID == null)
                {
                    ResultCode = "2903";
                }
                else if (!bLLUsers.verifyUserID(requestData.ParentID, requestData.AccessToken))
                {
                    ResultCode = "2904";
                }
                else if (requestData.BusID == string.Empty || requestData.BusID == null)
                {
                    ResultCode = "2905";
                }
                else
                {
                    UserInfo userInfo = bLLUsers.GetuserInfo(requestData.ParentID);
                    string[] userids = bLLBus.getUserIDListByBusID(userInfo.selectbusid);
                    if (userids != null)
                    {
                        if (userids.Contains(requestData.ParentID))
                        {
                            List<string> arrayList = userids.ToList();
                            for (int i = 0; i < arrayList.Count; i++)
                            {
                                if (arrayList[i].Equals(requestData.ParentID))
                                {
                                    arrayList.RemoveAt(i);
                                }
                            }
                            string[] newuserids = arrayList.ToArray();
                            int row1 = bLLBus.updateUseridList(userInfo.selectbusid, newuserids);
                            if (row1 ==0)
                            {
                                ResultCode = "2906";
                            }
                        }
                    }
                    if (!ResultCode.Equals("2906"))
                    {
                        int row = bLLUsers.updateSelectBusID(requestData.ParentID, requestData.BusID);
                        if (row == 0)
                        {
                            ResultCode = "2906";
                        }
                        else
                        {
                            string stringUserids = bLLBus.getStringUserIDListByBusID(requestData.BusID);
                            if (stringUserids == null)
                            {
                                stringUserids = requestData.ParentID;
                            }
                            else
                            {
                                string[] oldUserids = stringUserids.Split(',');
                                if (!oldUserids.Contains(requestData.ParentID))
                                {
                                    stringUserids = stringUserids + "," + requestData.ParentID;
                                }
                            }
                            int row2 = bLLBus.updateStringUseridList(requestData.BusID, stringUserids);
                            if (row2 ==0)
                            {
                                ResultCode = "2906";
                            }
                            else
                            {
                                ResultCode = "0000";
                            }
                        }
                    }

                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("UploadParentSelectedVehicle ResultCode====" + ResultCode);
                Utils.WriteTraceLog("UploadParentSelectedVehicle end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("UploadParentSelectedVehicle Exception " + ex);
                Utils.WriteTraceLog("UploadParentSelectedVehicle ResultCode====9991");
                Utils.WriteTraceLog("UploadParentSelectedVehicle end");
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