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
    /// requestParentAddVehicle 的摘要说明
    /// </summary>
    public class UploadParentAddVehicle : IHttpHandler
    {
        private class RequestData
        {
            public string AccessToken { get; set; }
            public string ParentID { get; set; }
            public string BusID { get; set; }
            public string BusPWD { get; set; }
        }
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                Utils.WriteTraceLog("UploadParentAddVehicle start");
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
                    ResultCode = "2801";
                }
                else if (requestData.AccessToken == string.Empty || requestData.AccessToken == null)
                {
                    ResultCode = "2802";
                }
                else if (requestData.ParentID == string.Empty || requestData.ParentID == null)
                {
                    ResultCode = "2803";
                }
                else if (!bLLUsers.verifyUserID(requestData.ParentID, requestData.AccessToken))
                {
                    ResultCode = "2804";
                }
                else if (!bLLBus.verifyBusPwd(requestData.BusID, requestData.BusPWD))
                {
                    ResultCode = "2805";
                }
                else
                {
                    string useridListString = bLLBus.getStringUserIDListByBusID(requestData.BusID);
                    if (useridListString == null )
                    {
                        useridListString = requestData.ParentID;
                    }
                    else
                    {
                        string[] userids = useridListString.Split(',');
                        if (!userids.Contains(requestData.ParentID))
                        {
                            useridListString = useridListString + "," + requestData.ParentID;
                        }

                    }
                    int row = bLLBus.updateStringUseridList(requestData.BusID, useridListString);
                    if (row == 0)
                    {
                        ResultCode = "2806";
                    }
                    else
                    {
                        UserInfo userInfo = bLLUsers.GetuserInfo(requestData.ParentID);
                        if (userInfo.busarray == null || userInfo.busarray == string.Empty)
                        {
                            userInfo.busarray = requestData.BusID;
                        }
                        else
                        {
                            string[] busArray = userInfo.busarray.Split(',');
                            if (!busArray.Contains(requestData.BusID))
                            {
                                userInfo.busarray = userInfo.busarray + "," + requestData.BusID;
                            }
                        }
                        int row1 = bLLUsers.updateBusArray(requestData.ParentID, userInfo.busarray);
                        if (row1 == 0)
                        {
                            ResultCode = "2807";
                        }
                        else
                        {
                            ResultCode = "0000";
                        }
                    }
                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("UploadParentAddVehicle ResultCode====" + ResultCode);
                Utils.WriteTraceLog("UploadParentAddVehicle end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("UploadParentAddVehicle Exception " + ex);
                Utils.WriteTraceLog("UploadParentAddVehicle ResultCode====9991");
                Utils.WriteTraceLog("UploadParentAddVehicle end");
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