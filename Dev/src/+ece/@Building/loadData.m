
 function bldg=loadData(obj, fileName)
 % Loads all input data for the building from file
            obj=obj.ReadSourceData(fileName);
            obj.LocationCity = "Boston";
            obj.LocationState = "MA";
            obj.matchCityLocation;

            obj.Pumps = ece.Pump.ReadSourceData(fileName);
            obj.GlazedSurfaces = ece.Glazing.ReadSourceData(fileName);
            obj.OpaqueSurfaces = ece.OpaqueSurface.ReadSourceData(fileName);
            obj.SlabOnGrade = ece.SlabOnGrade.ReadSourceData(fileName);
            obj.BelowGradeSurfaces = ece.BelowGradeSurface.ReadSourceData(fileName);
            obj.Spaces = ece.Space.ReadSourceData(fileName);
            obj.DHWsystems = ece.DHWsystem.ReadSourceData(fileName);
            obj.DHWtanks = ece.DHWtanks.ReadSourceData(fileName);
            obj.DHWpipesMechRoom = ece.DHWpipesMechRoom.ReadSourceData(fileName);
            obj.PlumbingFixtures = ece.PlumbingFixture.ReadSourceData(fileName);
            obj.Appliances = ece.Appliance.ReadSourceData(fileName);
            obj.Airmovers = ece.Airmovers.ReadSourceData(fileName);
            obj.HeatCool = ece.HeatCool.ReadSourceData(fileName);
            bldg=obj;
  end