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
    public class BLLDrivers
    {
        private DalTableDrivers dalDrivers;
        public BLLDrivers()
        {
            dalDrivers = new DalTableDrivers();
        }

        /// <summary>
        /// is user exist
        /// </summary>
        /// <param name="userID"></param>
        /// <returns>true,false</returns>
        public bool IsDriverIDExists(string driverId)
        {
            return dalDrivers.checkIfExistInBoth(driverId);
        }

        public bool isDriver(string driverId)
        {
            return dalDrivers.IsDriverExists(driverId);
        }

        public string GetAccessToken(string driverId, string pwd)
        {
            return dalDrivers.GetAccessToken(driverId, pwd);
        }

        public bool InsertDriverInfo(DriverModel driverInfo)
        {
            int no = dalDrivers.GenNextNo();
            return dalDrivers.InsertDriverInfo(no, driverInfo);
        }

        public DriverModel GetDriverInfo(string driverID, string pwd)
        {
            return dalDrivers.GetDriverInfo(driverID, pwd);
        }

        public string RegisterDriver(DriverModel driverInfo)
        {
            string resultStr = string.Empty;
            if (!Utils.ValidationLoginID(driverInfo.driverid))
            {
                resultStr = "2002";//用户ID不合法
            }  
            else if (driverInfo.drivername == string.Empty)
            {
                resultStr = "2003";//用户名字为空               
            }
            else if (!Utils.ValidationPwd(driverInfo.driverpwd))
            {
                resultStr = "2004";//用户密码不合法
            }
            else if (driverInfo.address == string.Empty)
            {
                resultStr = "2005";//用户地址为空
            }
            else if (IsDriverIDExists(driverInfo.driverid))
            {
                resultStr = "2006";//用户已经存在
            }
            else
            {

                if (InsertDriverInfo(driverInfo))
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
        public bool verifyDriverID(string driverid, string accesstoken)
        {
            return dalDrivers.verifyDriverID(driverid,accesstoken);
        }
    }
}
