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
    /// requestGetSchoolState 的摘要说明
    /// </summary>
    public class GetAbsentState : IHttpHandler
    {
        private class RequestData
        {
            public string StudentID { get; set; }
            public string CurrentDate { get; set; }
        }
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                Utils.WriteTraceLog("GetAbsentState start");
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
                    ResultCode = "3101";
                }
                else if (requestData.StudentID == string.Empty || requestData.StudentID == null)
                {
                    ResultCode = "3102";
                }
                else if (requestData.CurrentDate == string.Empty || requestData.CurrentDate == null)
                {
                    ResultCode = "3103";
                }
                else
                {
                    ResultCode = "0000";
                    AbsentInfo absentInfo = new AbsentInfo();
                    absentInfo.absentdate = requestData.CurrentDate;
                    absentInfo.absentuserid = requestData.StudentID;
                    bool isExist = bLLAbsent.isRecordExist(absentInfo);
                    if (isExist)
                    {
                        dict.Add("AbsentStatus", "true");
                    }
                    else
                    {
                        dict.Add("AbsentStatus", "false");
                    }
                }
                dict.Add("ResultCode", ResultCode);
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("GetAbsentState ResultCode====" + ResultCode);
                Utils.WriteTraceLog("GetAbsentState end");
            }
            catch (Exception ex)
            {
                Dictionary<string, string> dict = new Dictionary<string, string>();
                JavaScriptSerializer jsSerializer = new JavaScriptSerializer();
                dict.Add("ResultCode", "9991");
                context.Response.ContentType = "text/html";
                context.Response.Write(jsSerializer.Serialize(dict));
                Utils.WriteTraceLog("GetAbsentState Exception "+ex);
                Utils.WriteTraceLog("GetAbsentState ResultCode====9991");
                Utils.WriteTraceLog("GetAbsentState end");
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