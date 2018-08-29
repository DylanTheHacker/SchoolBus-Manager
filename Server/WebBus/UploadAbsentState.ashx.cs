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
    /// requestUploadSchoolState 的摘要说明
    /// </summary>
    public class UploadAbsentState : IHttpHandler
    {
        private class RequestData
        {
            public string AccessToken { get; set; }
            public string ParentID { get; set; }
            public string CurrentDate { get; set; }
            public string AbsentState { get; set; }
        }
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                Utils.WriteTraceLog("UploadAbsentState start");
                StreamReader reader = new StreamReader(context.Request.InputStream);
                string str = reader.ReadToEnd();
                reader.Close();
                string ResultCode = string.Empty;
                BLLBus bLLBus = new BLLBus();
                BLLUsers bLLUsers = new BLLUsers();
                BLLAbsent bLLAbsent = new BLLAbsent();
                Dictionary<string, object> dict = new Dictionary<string, object>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                RequestData requestData = jsSerializer.Deserialize<RequestData>(str);
                if (requestData == null)
                {
                    ResultCode = "3001";
                }
                else if (requestData.AccessToken == string.Empty || requestData.AccessToken == null)
                {
                    ResultCode = "3002";
                }
                else if (requestData.ParentID == string.Empty || requestData.ParentID == null)
                {
                    ResultCode = "3003";
                }
                else if (!bLLUsers.verifyUserID(requestData.ParentID, requestData.AccessToken))
                {
                    ResultCode = "3004";
                }
                else if (requestData.CurrentDate == string.Empty || requestData.CurrentDate == null)
                {
                    ResultCode = "3005";
                }
                else if (requestData.AbsentState == string.Empty || requestData.AbsentState == null)
                {
                    ResultCode = "3007";
                }
                else
                {
                    AbsentInfo absentInfo = new AbsentInfo();
                    absentInfo.absentdate = requestData.CurrentDate;
                    absentInfo.absentuserid = requestData.ParentID;
                    bool result = false;
                    if (requestData.AbsentState.Equals("true"))
                    {
                        result = bLLAbsent.insertAbsentInfo(absentInfo);
                    }
                    else if (requestData.AbsentState.Equals("false"))
                    {
                        result = bLLAbsent.deleteAbsentInfo(absentInfo);
                    }
                    if (!result)
                    {
                        ResultCode = "3006";
                    }
                    else
                    {
                        ResultCode = "0000";
                    }
                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("UploadAbsentState ResultCode====" + ResultCode);
                Utils.WriteTraceLog("UploadAbsentState end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("UploadAbsentState Exception " + ex);
                Utils.WriteTraceLog("UploadAbsentState ResultCode====9991");
                Utils.WriteTraceLog("UploadAbsentState end");
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