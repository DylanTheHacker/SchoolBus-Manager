using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL;
using Model;
using Common;

namespace BLL
{
    public class BLLUsers
    {
        private DalTableUsers dalUsers;
        public BLLUsers()
        {
            dalUsers = new DalTableUsers();
        }

        /// <summary>
        /// is user exist
        /// </summary>
        /// <param name="userID"></param>
        /// <returns>true,false</returns>
        public bool IsUserIDExists(string userID)
        {
            return dalUsers.checkIfExistInBoth(userID);
        }

        public bool InsertUserInfo(UserInfo userInfo)
        {
            int no = dalUsers.GenNextNo();
            return dalUsers.InsertUserInfo(no, userInfo);
        }

        public string RegisterParent(UserInfo userInfo)
        {
            string resultStr = string.Empty;          
            if(!Utils.ValidationLoginID(userInfo.userid))
            {
                resultStr = "2002";//用户ID不合法
            }
            else if(userInfo.username == string.Empty)
            {
                resultStr = "2003";//用户名字为空               
            }            
            else if (!Utils.ValidationPwd(userInfo.userpwd))
            {
                resultStr = "2004";//用户密码不合法
            }
            else if (userInfo.address == string.Empty)
            {
                resultStr = "2005";//用户地址为空
            }
            else if(IsUserIDExists(userInfo.userid))
            {
                resultStr = "2006";//用户已经存在
            }
            else
            {
                
                if(InsertUserInfo(userInfo))
                {
                    resultStr = "0000";//注册成功
                }
                else
                {
                    resultStr = "2007";//注册失败
                }
            }
            return resultStr;
        }

        public string GetAccessToken(string userID, string pwd)
        {
            return dalUsers.GetAccessToken(userID, pwd);
        }

        public UserInfo GetuserInfo(string userID)
        {
           return dalUsers.GetuserInfo(userID);
        }

        public bool verifyUserID(string userid, string accesstoken)
        {
            return dalUsers.verifyUserID(userid, accesstoken);
        }

        public int updateBusArray(string userid, string busarray)
        {
            return dalUsers.updateBusArray(userid,busarray);
        }

        public int updateSelectBusID(string userid, string busid)
        {
            return dalUsers.updateSelectBusID(userid,busid);
        }

        public bool deleteSelectedVehicle(string userid, string busid)
        {
            UserInfo userInfo = GetuserInfo(userid);
            List<string> busList = userInfo.busarray.Split(',').ToList();
            busList.Remove(busid);
            string busListString = string.Join(",",busList.ToArray());
            int row = updateBusArray(userid, busListString);
            if (row<=0)
            {        
                return false;
            }
            if (!userInfo.selectbusid.Equals(busid))
            {
                return true;
            }
            row = updateSelectBusID(userid,"");
            if (row <= 0)
            {
                return false;
            }
            else
            {
                return true;
            }
        }
    }
}
